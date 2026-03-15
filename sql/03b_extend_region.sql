-- Purpose: update region validation constraints across warehouse tables
-- Context:
    -- The project was originally designed to analyze short-haul markets in Canada and the EU.
    -- Due to limited availability of suitable datasets for those regions, the analysis pivoted to U.S. DOT T-100 traffic data.
    -- As a result, 'US' was added to the list of valid regions.
    -- This script updates CHECK constraints to allow ('CA','US','EU').

ALTER TABLE dim_airport
DROP CONSTRAINT IF EXISTS chk_region;

ALTER TABLE dim_airport
ADD CONSTRAINT chk_region CHECK (region IN ('CA', 'US', 'EU'));

ALTER TABLE fact_route_month
DROP CONSTRAINT IF EXISTS chk_frm_region;

ALTER TABLE fact_route_month
ADD CONSTRAINT chk_frm_region CHECK (region IN ('CA', 'US', 'EU'));

ALTER TABLE fact_price_period
DROP CONSTRAINT IF EXISTS chk_fpp_region;

ALTER TABLE fact_price_period
ADD CONSTRAINT chk_fpp_region CHECK (region IN ('CA', 'US', 'EU'));