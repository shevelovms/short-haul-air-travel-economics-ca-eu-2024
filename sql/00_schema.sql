CREATE TABLE IF NOT EXISTS dim_airport (
  airport_code CHAR(3) PRIMARY KEY,
  airport_name TEXT,
  country TEXT,
  region TEXT NOT NULL,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  CONSTRAINT chk_region CHECK (region IN ('CA', 'EU'))
);

CREATE TABLE IF NOT EXISTS dim_route (
  route_id TEXT PRIMARY KEY,
  origin_airport CHAR(3) NOT NULL,
  dest_airport CHAR(3) NOT NULL,
  distance_km INTEGER,
  CONSTRAINT chk_route_order CHECK (origin_airport <= dest_airport),
  CONSTRAINT uq_route_pair UNIQUE (origin_airport, dest_airport)
);

CREATE TABLE IF NOT EXISTS fact_route_month (
  region TEXT NOT NULL,
  year SMALLINT NOT NULL,
  month SMALLINT NOT NULL,
  route_id TEXT NOT NULL,
  carrier TEXT NOT NULL,
  flights_count INTEGER NOT NULL,
  CONSTRAINT chk_frm_region CHECK (region IN ('CA', 'EU')),
  CONSTRAINT chk_frm_month CHECK (month BETWEEN 1 AND 12),
  CONSTRAINT pk_fact_route_month PRIMARY KEY (region, year, month, route_id, carrier)
);

CREATE TABLE IF NOT EXISTS fact_price_period (
  region TEXT NOT NULL,
  year SMALLINT NOT NULL,
  period_type TEXT NOT NULL,
  period_num SMALLINT NOT NULL,
  metric_name TEXT NOT NULL,
  metric_value DOUBLE PRECISION,
  CONSTRAINT chk_fpp_region CHECK (region IN ('CA', 'EU')),
  CONSTRAINT chk_period_type CHECK (period_type IN ('monthly', 'quarterly'))
);

CREATE TABLE IF NOT EXISTS stg_airports_raw (
  source TEXT NOT NULL,
  airport_code TEXT,
  airport_name TEXT,
  country TEXT,
  latitude TEXT,
  longitude TEXT,
  load_ts TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
