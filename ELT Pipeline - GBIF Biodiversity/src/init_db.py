import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

# Load .env file from Project ROOT
ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "dbname": os.getenv("POSTGRES_DB"),
}

# Meta table is about the pipeline performance
SQL = """
CREATE SCHEMA IF NOT EXISTS raw;
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS marts;
CREATE SCHEMA IF NOT EXISTS meta;

CREATE TABLE IF NOT EXISTS meta.etl_run(    
    run_id TEXT PRIMARY KEY,
    pipeline TEXT NOT NULL,
    status TEXT NOT NULL,
    row_count BIGINT,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    notes TEXT);
"""


 # load env → connect → create schemas → create meta table → print success
def main() -> None:
    missing = [ k for k, v in DB_CONFIG.items() if not v ]
    if missing:
        raise SystemExit(f"Missing DB settings: {missing}. Check .env")

    with psycopg.connect(**DB_CONFIG) as conn:   
        with conn.cursor() as cur:          # A cursor is the object that sends SQL and reads results.
            cur.execute(SQL)            # Another with so the cursor is closed when done.
        conn.commit()  

    print("Schemas + meta.etl_runs created successfully.")

# “Only run main() when this file is executed directly — not when another file imports it.”
if __name__ == "__main__":
    main()

# -----------------------------------
# VALIDATION STEP....

# Fail clearly if .env is incomplete
# for key, value in conn_kwargs.items():
#     if not value:
#         raise SystemExit(f"Missing required environment variable: {key}")

# Check that psycopg is installed and can connect to the database.
# psycopg.connect(...) opens a connection to Postgres using your host/user/password/db.
# **conn_kwargs unpacks the dict into keyword args, same as writing host=..., user=..., etc.
# with ... as conn is a context manager: when the block ends (success or error), the connection is closed automatically.
# with psycopg.connect(**conn_kwargs) as conn:   
#     with conn.cursor() as cur:          # A cursor is the object that sends SQL and reads results.
#         cur.execute("SELECT version();")            # Another with so the cursor is closed when done.
#         print(cur.fetchone()[0])

# with psycopg.connect(**conn_kwargs) as conn:
#     with conn.cursor() as cur:
#         cur.execute(SCHEMA_SQL)
#     conn.commit()  # Commit the transaction to make changes persistent in the database.
#     print("Schema created!")

# print("DB_name:", os.getenv("POSTGRES_DB"))
# print("USER:", os.getenv("POSTGRES_USER"))

