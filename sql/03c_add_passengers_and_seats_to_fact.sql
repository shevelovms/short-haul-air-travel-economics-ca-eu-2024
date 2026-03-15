-- Purpose: extend the fact table schema with passenger and seat metrics
-- Notes:
    -- these columns were added after the initial table creation
    -- these metrics are sourced from the T-100 segment dataset

ALTER TABLE fact_route_month
ADD COLUMN IF NOT EXISTS passengers INTEGER;

ALTER TABLE fact_route_month
ADD COLUMN IF NOT EXISTS seats INTEGER;