import pandas as pd
from pathlib import Path

# --- Paths ---
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_PATH = BASE_DIR / "data_raw" / "ourairports_airports.csv"
OUTPUT_PATH = BASE_DIR / "data_processed" / "airports_seed.csv"

# --- EU27 + CA + US + GB ---
ALLOWED_COUNTRIES = {
    "CA", "US", "GB",
    "AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE",
    "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV",
    "LT", "LU", "MT", "NL", "PL", "PT", "RO",
    "SK", "SI", "ES", "SE"
}

def main():
    # Load raw data
    df = pd.read_csv(RAW_PATH)

    # Keep only required columns
    df = df[[
        "iata_code",
        "name",
        "iso_country",
        "latitude_deg",
        "longitude_deg"
    ]]

    # Drop rows without IATA code
    df = df[df["iata_code"].notna()]

    # Keep only 3-letter IATA codes
    df = df[df["iata_code"].str.len() == 3]

    # Filter countries
    df = df[df["iso_country"].isin(ALLOWED_COUNTRIES)]

    # Rename columns to match staging schema
    df = df.rename(columns={
        "iata_code": "airport_code",
        "name": "airport_name",
        "iso_country": "country",
        "latitude_deg": "latitude",
        "longitude_deg": "longitude"
    })

    # Uppercase airport codes
    df["airport_code"] = df["airport_code"].str.upper()

    # Drop duplicate airport codes
    df = df.drop_duplicates(subset=["airport_code"])

    # Add source column
    df.insert(0, "source", "ourairports")

    # Ensure output directory exists
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Save
    df.to_csv(OUTPUT_PATH, index=False)

    print(f"Seed file written to: {OUTPUT_PATH}")
    print(f"Rows: {len(df)}")

if __name__ == "__main__":
    main()