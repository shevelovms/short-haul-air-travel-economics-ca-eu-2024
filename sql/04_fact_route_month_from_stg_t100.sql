-- Purpose: load US route-carrier-month records from staging into the fact table
-- Grain: one row per region, year, month, route_id, and carrier
-- Notes:
    -- deletes the existing US data first so the load is repeatable
    -- assigns region = 'US' explicitly because the current staging table contains US T-100 data
    -- rounds numeric staging fields before casting them to INTEGER

DELETE FROM fact_route_month WHERE region = 'US';

INSERT INTO fact_route_month (region, year, month, route_id, carrier, flights_count, passengers, seats)
SELECT
    'US',
    year,
    month,
    route_id,
    unique_carrier,
    ROUND(flights_count)::INTEGER,
    ROUND(passengers)::INTEGER,
    ROUND(seats)::INTEGER
FROM stg_t100_route_carrier_month;