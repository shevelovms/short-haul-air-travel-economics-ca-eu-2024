-- Question: What are the 10 highest-frequency US domestic routes in 2024?
-- Filters: 300–1200 km, domestic routes only, >50 flights/year/route
-- Grain before final ranking: route_id

WITH base AS (
    SELECT
        frm.route_id,
        frm.flights_count,
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

flights_per_route AS (
    SELECT
        route_id,
        route_region,
        SUM(flights_count) AS total_flights
    FROM base
    WHERE
        distance_km BETWEEN 300 AND 1200
        AND route_region IN ('US', 'CA', 'EU')
    GROUP BY route_id, route_region
    HAVING SUM(flights_count) > 50
)

SELECT
    route_id,
    route_region,
    total_flights,
    DENSE_RANK() OVER (PARTITION BY route_region ORDER BY total_flights DESC) AS r
FROM flights_per_route
ORDER BY total_flights DESC
LIMIT 10;