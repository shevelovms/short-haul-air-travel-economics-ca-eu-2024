-- Purpose: build the route dimension from staged T-100 route data
-- Grain: one row per directional route_id
-- Notes:
    -- origin and destination airports are parsed from route_id (AAA-BBB)
    -- MAX(distance_km) is used because the same route appears across multiple
    -- carrier-month records in staging, while route distance should remain constant

TRUNCATE dim_route;

INSERT INTO dim_route (route_id, origin_airport, dest_airport, distance_km)
SELECT
    route_id,
    SPLIT_PART(route_id, '-', 1) AS origin_airport,
    SPLIT_PART(route_id, '-', 2) AS dest_airport,
    MAX(distance_km) AS distance_km
FROM stg_t100_route_carrier_month
WHERE route_id LIKE '___-___'
GROUP BY route_id, origin_airport, dest_airport;