-- Question: Which routes have the most carriers operating in 2024?
-- Filters: passenger carriers only, >50 flights/year/carrier
-- Grain before final ranking: route_id

WITH ingestion AS (
    SELECT
        route_id,
        carrier,
        flights_count,
        passengers
FROM fact_route_month
WHERE year = 2024
),

grouped AS (
    SELECT
        route_id,
        carrier,
        SUM(flights_count) AS total_flights,
        SUM(passengers) AS total_passengers
    FROM ingestion
    GROUP BY route_id, carrier
)

SELECT
    route_id,
    COUNT(DISTINCT carrier) AS carrier_num
FROM grouped
WHERE
    total_flights > 50
    AND total_passengers > 0
GROUP BY 1
ORDER BY carrier_num DESC
LIMIT 5;