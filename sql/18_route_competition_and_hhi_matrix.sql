-- Purpose: define how many routes fall into each combination of carrier-count bucket and HHI bucket
-- Intermediate grain: one row per route_id
-- Final output: route counts by carrier-count bucket and HHI bucket
-- Filters: US domestic, 2024, 300–1200 km, passenger carriers only, >50 annual flights per carrier
-- Metric: HHI is calculated from each carrier's share of annual route-level flights

WITH short_haul_domestic_flights AS (
    SELECT
        frm.route_id,
        frm.carrier,
        frm.flights_count,
        frm.passengers
    FROM fact_route_month AS frm
    INNER JOIN dim_route AS dr ON frm.route_id = dr.route_id
    WHERE frm.year = 2024
        AND dr.distance_km BETWEEN 300 AND 1200
        AND frm.region = 'US'
),

flights_passengers_per_route AS (
    SELECT
        route_id,
        carrier,
        SUM(flights_count) AS total_flights_per_carrier,
        SUM(passengers) AS total_passengers_per_carrier
    FROM short_haul_domestic_flights
    GROUP BY route_id, carrier
),

eligible_carriers AS (
    SELECT
        route_id,
        carrier,
        total_flights_per_carrier
    FROM flights_passengers_per_route
    WHERE total_flights_per_carrier > 50
        AND total_passengers_per_carrier > 0
),

-- Build the eligible route-carrier backbone used by both competition metrics.

eligible_carriers_with_route_totals AS (
    SELECT
        route_id,
        carrier,
        total_flights_per_carrier,
        SUM(total_flights_per_carrier) OVER (PARTITION BY route_id) AS total_flights_per_route
    FROM eligible_carriers
),

-- Branch A: classify routes by the number of eligible carriers.

carrier_count AS (
    SELECT
        route_id,
        COUNT(*) AS unique_carriers_per_route
    FROM eligible_carriers_with_route_totals
    GROUP BY route_id
),

route_competition_classification AS (
    SELECT
        route_id,
        unique_carriers_per_route,
        CASE
            WHEN unique_carriers_per_route = 1 THEN 'monopoly'
            WHEN unique_carriers_per_route = 2 THEN 'duopoly'
            ELSE 'competitive'
        END AS route_competition
    FROM carrier_count
),

-- Branch B: compute route-level HHI from carrier flight shares.

route_carrier_shares AS (
    SELECT
        route_id,
        100.0 * (total_flights_per_carrier::float / total_flights_per_route::float) AS share
    FROM eligible_carriers_with_route_totals
),

route_carrier_share_squares AS (
    SELECT
        route_id,
        (share * share) AS share_sq
    FROM route_carrier_shares
),

route_hhi AS (
    SELECT
        route_id,
        SUM(share_sq) AS route_hhi
    FROM route_carrier_share_squares
    GROUP BY route_id
),

route_hhi_classification AS (
    SELECT
        route_id,
        route_hhi,
        CASE
            WHEN route_hhi < 1500 THEN 'low'
            WHEN route_hhi BETWEEN 1500 AND 2500 THEN 'moderate'
            ELSE 'high'
        END AS hhi_ranking
    FROM route_hhi
),

-- Combine carrier-count classification with route-level HHI.

route_competition_vs_hhi AS (
    SELECT
        c.route_id,
        c.unique_carriers_per_route,
        c.route_competition,
        rhc.route_hhi,
        rhc.hhi_ranking
    FROM route_competition_classification AS c
    INNER JOIN route_hhi_classification AS rhc
        ON c.route_id = rhc.route_id
)

-- Build the matrix of route_competition and HHI.

SELECT
    route_competition,
    hhi_ranking,
    COUNT(*) AS routes
FROM route_competition_vs_hhi
GROUP BY route_competition, hhi_ranking
ORDER BY routes DESC;