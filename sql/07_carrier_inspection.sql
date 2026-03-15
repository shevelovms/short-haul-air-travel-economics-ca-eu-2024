-- Diagnostic: Inspect carrier presence on LAS-LAX in 2024
-- Purpose: verify competition level and carrier mix for a known busy route
-- Grain: carrier

SELECT carrier,
       SUM(flights_count) AS flights
FROM fact_route_month
WHERE year = 2024
  AND route_id = 'LAS-LAX'
  AND region = 'US'
GROUP BY carrier
ORDER BY flights DESC;