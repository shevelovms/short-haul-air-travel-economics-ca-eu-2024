-- Question: What are the 10 most competitive US domestic routes in 2024?
-- Filters: 300–1200 km, domestic routes only, passenger carriers only, >50 flights/year/carrier-on-route
-- Grain before final ranking: route_id

WITH base AS (
    SELECT
        frm.route_id,
        frm.carrier,
        frm.flights_count,
        frm.passengers,
        dr.distance_km,
        CASE
            WHEN dao.region = dad.region THEN dao.region
            ELSE 'crossborder'
        END AS route_region
    FROM fact_route_month AS frm
    INNER JOIN dim_route AS dr ON frm.route_id = dr.route_id
    INNER JOIN dim_airport AS dao ON dr.origin_airport = dao.airport_code
    INNER JOIN dim_airport AS dad ON dr.dest_airport = dad.airport_code
    WHERE frm.year = 2024
),

flights_passengers_per_route AS (
    SELECT
        route_id,
        carrier,
        route_region,
        SUM(flights_count) AS total_flights,
        SUM(passengers) AS total_passengers
    FROM base
    WHERE distance_km BETWEEN 300 AND 1200
    GROUP BY route_id, carrier, route_region
),

carriers_per_route_domestic AS (
    SELECT
        route_id,
        COUNT(*) AS unique_carriers_per_route,
        route_region
    FROM flights_passengers_per_route
    WHERE
        route_region IN ('US', 'CA', 'EU')
        AND total_flights > 50
        AND total_passengers > 0
    GROUP BY route_id, route_region
)

SELECT
    route_id,
    route_region,
    unique_carriers_per_route,
    DENSE_RANK() OVER (PARTITION BY route_region ORDER BY unique_carriers_per_route DESC) AS r
FROM carriers_per_route_domestic
ORDER BY unique_carriers_per_route DESC
LIMIT 10;