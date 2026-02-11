-- Canonicalize an airport-pair route so (A,B) == (B,A)

-- origin_airport_canon:
LEAST(origin_airport, dest_airport)

-- dest_airport_canon:
GREATEST(origin_airport, dest_airport)

-- route_id (deterministic):
LEAST(origin_airport, dest_airport) || '-' || GREATEST(origin_airport, dest_airport)
