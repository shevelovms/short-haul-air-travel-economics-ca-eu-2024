-- Purpose: populate the airport dimension from raw airport staging data
-- Grain: one row per airport (IATA code)
-- Notes:
    -- Airport_code is trimmed and uppercased to ensure standardized IATA codes.
    -- Only valid 3-character codes are retained.
    -- Region is derived from the airport country to support regional analysis.
    -- Latitude and longitude are explicitly cast to DOUBLE PRECISION to enforce.
    -- Consistent numeric types in the warehouse schema.

TRUNCATE dim_airport;

INSERT INTO dim_airport (
    airport_code,
    airport_name,
    country,
    region,
    latitude,
    longitude
)
SELECT
    UPPER(TRIM(airport_code))::CHAR(3) AS airport_code,
    airport_name,
    country,
    CASE
        WHEN country = 'CA' THEN 'CA'
        WHEN country = 'US' THEN 'US'
        ELSE 'EU'
    END AS region,
    latitude::DOUBLE PRECISION AS latitude,
    longitude::DOUBLE PRECISION AS longitude
FROM stg_airports_raw
WHERE airport_code IS NOT NULL
    AND LENGTH(TRIM(airport_code)) = 3;