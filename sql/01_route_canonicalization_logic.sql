-- Purpose: canonicalize directional airport routes into undirected airport pairs.
-- Rationale:
    -- Airline competition analysis is performed at the city-pair level.
    -- Routes such as (A,B) and (B,A) represent the same market and must be standardized into a deterministic route identifier.

-- Canonical origin airport
LEAST(origin_airport, dest_airport) AS origin_airport_canon,

-- Canonical destination airport
GREATEST(origin_airport, dest_airport) AS dest_airport_canon,

-- Canonical route_id
LEAST(origin_airport, dest_airport) || '-' ||
GREATEST(origin_airport, dest_airport) AS route_id