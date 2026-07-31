import os
from pathlib import Path

import psycopg
from dotenv import load_dotenv

# Load .env file from Project ROOT
ROOT = Path(__file__).resolve().parents[1]
load_dotenv(ROOT / ".env")

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "dbname": os.getenv("POSTGRES_DB"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
}

SQL = """
    CREATE TABLE IF NOT EXISTS raw.gbif_occurrences (
        gbif_key            BIGINT PRIMARY KEY,
        scientific_name     TEXT,
        taxon_key           BIGINT,
        kingdom             TEXT,
        phylum              TEXT,
        class               TEXT,
        order_name          TEXT,
        family              TEXT,
        genus               TEXT,
        species             TEXT,
        country_code        TEXT,
        decimal_latitude    DOUBLE PRECISION,
        decimal_longitude   DOUBLE PRECISION,
        event_date          TEXT,
        year                INT,
        month               INT,
        dataset_key         TEXT,
        basis_of_record     TEXT,
        ingested_at         TIMESTAMPTZ DEFAULT now(),
        source_file         TEXT,
        raw_payload         JSONB
    );
"""

def main():
    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            cur.execute(SQL)
        conn.commit()
    
    print("Complete creating table.")

if __name__ == "__main__":
    main()