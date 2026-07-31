from pathlib import Path
import json
import os
from dotenv import load_dotenv
import psycopg
import uuid
from datetime import datetime, timezone

ROOT = Path(__file__).resolve().parents[1]
LANDING = ROOT / "data" / "landing" / "occurrences"
load_dotenv(ROOT / ".env")

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "localhost"),
    "user": os.getenv("POSTGRES_USER"),
    "password": os.getenv("POSTGRES_PASSWORD"),
    "dbname": os.getenv("POSTGRES_DB"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
}

def list_page_files() -> list[Path]:
    files = sorted(LANDING.glob("dt=*/page_*.json"))
    if not files:
        raise SystemExit(f"No landing files under {LANDING}. Run gbif_client.py first.")
    return files

def record_to_row(rec: dict, source_file: str) -> tuple:
    return (
        rec.get("key"),
        rec.get("scientificName"),
        rec.get("taxonKey"),
        rec.get("kingdom"),
        rec.get("phylum"),
        rec.get("class"),
        rec.get("order"),               # API field → order_name column
        rec.get("family"),
        rec.get("genus"),
        rec.get("species"),
        rec.get("countryCode"),
        rec.get("decimalLatitude"),
        rec.get("decimalLongitude"),
        rec.get("eventDate"),
        rec.get("year"),
        rec.get("month"),
        rec.get("datasetKey"),
        rec.get("basisOfRecord"),
        source_file,
        json.dumps(rec),                # for JSONB
    )

INSERT_SQL = """
INSERT INTO raw.gbif_occurrences (
    gbif_key, scientific_name, taxon_key, kingdom, phylum, class, 
    order_name, family, genus, species, country_code,
    decimal_latitude, decimal_longitude, event_date, year, month, 
    dataset_key, basis_of_record, source_file, raw_payload
) VALUES (
    %s, %s, %s, %s, %s, %s,
    %s, %s, %s, %s, %s,
    %s, %s, %s, %s, %s,
    %s, %s, %s, %s::jsonb 
)
ON CONFLICT (gbif_key) DO UPDATE SET
    scientific_name = EXCLUDED.scientific_name,
    source_file = EXCLUDED.source_file,
    raw_payload = EXCLUDED.raw_payload,
    ingested_at = now(); 
"""

def load_all() -> int:
    files = list_page_files()
    total = 0
    started_at = datetime.now(timezone.utc)   # <-- add this

    with psycopg.connect(**DB_CONFIG) as conn:
        with conn.cursor() as cur:
            # Read each file, and paste data into a list
            for path in files:
                payload = json.loads(path.read_text(encoding="utf-8"))  # inside -> out: Step 1: file → string, Step 2: string → dict/list
                rows = []
                for rec in payload.get("results", []):
                    if rec.get("key") is None:
                        continue
                    rows.append(record_to_row(rec, str(path.relative_to(ROOT))))

                if rows:
                    cur.executemany(INSERT_SQL, rows)
                    total += len(rows)
                    print(f"Loaded {len(rows)} from {path.name}")
        
            run_id = str(uuid.uuid4())
            cur.execute(
                """
                INSERT INTO meta.etl_run (run_id, pipeline, status, row_count, started_at, finished_at, notes)
                VALUES (%s, %s, %s, %s, %s, %s, %s)
                """,
                (run_id, 
                "gbif_extract_load", 
                "success", 
                total, 
                started_at,  # save datetime before load starts
                datetime.now(timezone.utc), 
                "loaded from data/landing",
                ),
            )

        conn.commit()

    return total

if __name__ == "__main__":
    n = load_all()
    print(f"Complete load {n} rows.")
