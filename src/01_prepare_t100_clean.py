import pandas as pd
from pathlib import Path

# --- Paths ---
BASE_DIR = Path(__file__).resolve().parent.parent
RAW_PATH = BASE_DIR / "data_raw" / "t100_2024_raw.csv"
OUTPUT_PATH = BASE_DIR / "data_processed" / "t100_2024_route_carrier_month.csv"

def main():
    # Load raw data
    df_raw = pd.read_csv(RAW_PATH)

    # Store and print the number of raw rows (for sanity checks later)
    raw_rows = len(df_raw)
    print(f"The number of raw rows is: {raw_rows}")

    # Rename the DataFrame
    df = df_raw.copy()

    # Lowercase columns
    df.columns = df.columns.str.lower()

    # Uppercase airports and carrier names
    df["origin"] = df["origin"].str.upper().str.strip()
    df["dest"] = df["dest"].str.upper().str.strip()
    df["unique_carrier"] = df["unique_carrier"].str.upper().str.strip()

    # Cast 'distance' to numeric, then convert to km, and rename to 'distance_km'
    df["distance"] = pd.to_numeric(df["distance"], errors = "coerce")
    df["distance"] = df["distance"] * 1.60934
    df.rename(columns = {"distance": "distance_km"}, inplace = True)

    # Keep only required columns
    df = df[[
        "year",
        "month",
        "unique_carrier",
        "origin",
        "dest",
        "distance_km",
        "departures_performed",
        "passengers",
        "seats"
    ]]

    # Drop self-routes
    df = df[df["origin"] != df["dest"]]

    # Keep 2024 only
    df = df[df["year"] == 2024]

    # Cast to numeric
    df["departures_performed"] = pd.to_numeric(df["departures_performed"], errors = "coerce")
    df["passengers"] = pd.to_numeric(df["passengers"], errors = "coerce")
    df["seats"] = pd.to_numeric(df["seats"], errors = "coerce")
    df["distance_km"] = pd.to_numeric(df["distance_km"], errors = "coerce")

    # Drop rows with NaNs in the numeric fields
    df.dropna(subset = ["departures_performed",
            "passengers",
            "seats",
            "distance_km"
    ], inplace = True)

    # Remove useless rows
    df = df[df["departures_performed"] > 0]
    df = df[df["distance_km"] > 0]

    # Distance band filter
    df = df[(df["distance_km"] >= 300) & (df["distance_km"] <= 1200)]

    # Normalize route direction for later joins
    df["origin_canon"] = df[["origin", "dest"]].min(axis = 1)
    df["dest_canon"] = df[["origin", "dest"]].max(axis = 1)
    df["route_id"] = df["origin_canon"] + '-' + df["dest_canon"]

    # Store and print the number of filtered rows (for sanity checks later)
    filtered_rows = len(df)
    print(f"The number of filtered rows is: {filtered_rows}")

    # Create a GroupBy object and aggregate on it
    df_agg = (
        df.groupby(["year", "month", "route_id", "unique_carrier"],as_index = False)
        .agg({"departures_performed": "sum", "passengers": "sum", "seats": "sum", "distance_km": "max"})
        )

    # Rename 'departures_performed' to 'flights_count'
    df_agg.rename(columns = {"departures_performed": "flights_count"}, inplace = True)

    # Store and print the number of aggregated rows (for sanity checks later)
    agg_rows = len(df_agg)
    print(f"The number of aggregated rows is: {agg_rows}")

    # Print number of duplicates present
    key_cols = ["year", "month", "route_id", "unique_carrier"]
    dups = df_agg.duplicated(subset = key_cols).sum()
    print(f"Duplicates present: {dups}")
    
    # Show 5 random rows where 'flights_count' > 0
    print(df_agg[df_agg["flights_count"] > 0].sample(n = 5))

    # Ensure output directory exists
    OUTPUT_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Save
    df_agg.to_csv(OUTPUT_PATH, index = False)

    # Print output path, number of rows, min and max for 'distance_km', and perc of rows removed
    print(f"Seed file written to: {OUTPUT_PATH}")
    print(f"Rows: {len(df)}")
    print(f"Min distance_km: {min(df["distance_km"])}")
    print(f"Max distance_km: {max(df["distance_km"])}")
    filtered_perc = (raw_rows - filtered_rows) / raw_rows * 100
    aggregation_perc = (filtered_rows - agg_rows) / filtered_rows * 100
    print(f"# of rows removed after filtering: {filtered_perc}")
    print(f"# of rows removed after aggregation: {aggregation_perc}")

if __name__ == "__main__":
    main()