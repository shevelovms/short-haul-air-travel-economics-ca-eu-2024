Processed datasets generated during Python preprocessing.

Files in this directory are created by the preprocessing scripts in `src/`:

00_prepare_airports_seed.py
    Prepares airport reference data used for route enrichment.

01_prepare_t100_clean.py
    Cleans and standardizes the raw T100 airline dataset before loading into PostgreSQL.

These processed datasets serve as intermediate inputs for the analytical warehouse tables used in the SQL analysis.

Large data files are excluded from version control.