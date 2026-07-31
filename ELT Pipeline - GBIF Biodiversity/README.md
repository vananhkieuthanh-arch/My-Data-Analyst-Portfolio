# ELT Pipeline - GBIF Biodiversity

End-to-end ELT learning project: extract species occurrence data from the GBIF API, land files, load Postgres (`raw`), transform with dbt (`staging` / `marts`), orchestrate with Airflow.

## Architecture
GBIF API
  → Airflow (`extract_gbif`)
  → `data/landing/occurrences/`
  → Airflow (`load_raw`) → `raw.gbif_occurrences`
  → dbt (`stg` → dims/fact → marts)
  → analytics tables (e.g. species richness by month)

### Medallion layers
| Layer | Where | Role |
|-------|--------|------|
| Bronze | `raw` | API data + JSONB payload |
| Silver | `staging` (dbt) | cleaned / renamed |
| Gold | `marts` (dbt) | dims, fact, business marts |
| Meta | `meta.etl_run` | load run log |

## Stack
- Python (extract/load)
- Docker Compose (Postgres 16 + Airflow 2.9)
- dbt-postgres
- GBIF Occurrence Search API

## Data scope (learning)
- Country: VN
- Taxon: Aves (`taxonKey=212`)
- Year: 2023
- Caps: page size 300, max pages 5 (raise later)

## How to run

### 1. Setup
- Copy `.env.example` → `.env`
- `docker compose up -d`
- Create DB objects: `python src/init_db.py` then `python src/init_raw_table.py`

### 2. Manual path (without Airflow)
- `python src/gbif_client.py`
- `python src/load_raw.py`
- `cd dbt_project && dbt run --target dev && dbt test --target dev`

### 3. Orchestrated path
- Open http://localhost:8080
- Trigger DAG `gbif_etl`
- Tasks: extract → load → dbt_run → dbt_test

### 4. Check results
```sql
SELECT COUNT(*) FROM raw.gbif_occurrences;
SELECT * FROM meta.etl_run ORDER BY finished_at DESC LIMIT 5;
SELECT * FROM marts.mart_species_richness_by_month;```