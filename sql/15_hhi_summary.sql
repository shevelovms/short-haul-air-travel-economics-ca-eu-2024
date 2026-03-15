-- Purpose: Understand market concentration per route
-- Grain (before final summary): route_id
-- Final output: one row
-- Filters: 300–1200 km, domestic routes only, passenger carriers only, >50 flights/year/carrier
-- Metric: HHI is based on each carrier's share of annual flights on a route

WITH route_flights_base AS (
    SELECT
        frm.route_id,
        frm.carrier,
        frm.flights_count,
        frm.passengers,
        dr.distance_km
    FROM fact_route_month AS frm
    INNER JOIN dim_route AS dr ON frm.route_id = dr.route_id
    WHERE frm.year = 2024
        AND frm.region = 'US'
        AND dr.distance_km BETWEEN 300 AND 1200
),

route_carrier_totals AS (
    SELECT
        route_id,
        carrier,
        SUM(flights_count) AS total_flights,
        SUM(passengers) AS total_passengers
    FROM route_flights_base
    GROUP BY route_id, carrier
),

eligible_route_carriers AS (
    SELECT
        route_id,
        carrier,
        total_flights,
        SUM(total_flights) OVER (PARTITION BY route_id) AS total_flights_per_route
    FROM route_carrier_totals
    WHERE total_flights > 50
        AND total_passengers > 0
),

route_carrier_shares AS (
    SELECT
        route_id,
        carrier,
        100.0 * (total_flights::float / total_flights_per_route::float) AS share
    FROM eligible_route_carriers
),

route_carrier_share_squares AS (
    SELECT
        route_id,
        carrier,
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

route_hhi_ranges AS (
    SELECT
        route_id,
        route_hhi,
        CASE
            WHEN route_hhi < 1500 THEN 'low'
            WHEN route_hhi BETWEEN 1500 AND 2500 THEN 'moderate'
            ELSE 'high'
        END AS hhi_ranking
    FROM route_hhi
)

SELECT
    COUNT(*) AS total_routes,
    ROUND(100.0 * AVG((hhi_ranking = 'low')::int), 2) AS perc_low,
    ROUND(100.0 * AVG((hhi_ranking = 'moderate')::int), 2) AS perc_moderate,
    ROUND(100.0 * AVG((hhi_ranking = 'high')::int), 2) AS perc_high,
    PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY route_hhi) AS median_route_hhi
FROM route_hhi_ranges;