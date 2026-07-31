import json 
import time
from datetime import date
from pathlib import Path

import requests

# Layer 1 — Config + paths

ROOT = Path(__file__).resolve().parents[1]
BASE_URL = "https://api.gbif.org/v1/occurrence/search"

# Learning defaults — change later
# Hardcode filters at the top for now. CLI args / .env can come later.
COUNTRY = "VN"
TAXON_KEY = 212    # Aves
YEAR = 2023
PAGE_SIZE = 300    # GBIF max per page
MAX_PAGES = 5      # safety cap for first runs
SLEEP_SECONDS = 0.3

# Layer 2 — One page fetch function
def fetch_page(offset: int, limit: int = PAGE_SIZE) -> dict:    # In → Out: Input offset, Output dictionary
    params = {
        "country": COUNTRY,
        "taxonKey": TAXON_KEY, 
        "hasCoordinate": "true",
        "year": YEAR,
        "limit": limit,
        "offset": offset,
    }
    r = requests.get(BASE_URL, params=params, timeout=60)
    r.raise_for_status()
    return r.json()

# Layer 3 — Save one page
def landing_dir() -> Path:  # In → Out: Input nothing, Output Path
    d = (
        ROOT 
        / "data" 
        / "landing" 
        / "occurrences" 
        / f"dt={date.today().isoformat()}"
    )
    d.mkdir(parents=True, exist_ok=True)
    return d

def save_page(payload: dict, page_index: int) -> Path:          # In → Out: Input dictionary + page index, Output Path
    path = landing_dir() / f"page_{page_index:04d}.json"          # 04: Width 4, pad with leading 0 -> 0000, d: Format as a decimal integer
    path.write_text(json.dumps(payload), encoding="utf-8")      # Skip indent=2 for bulk (smaller/faster); keep indent only when debugging.
    return path

# Layer 4 — Pagination loop
def extract() -> int:       # In → Out: Input nothing, Output how many rows saved (int)
    offset = 0
    total_saved = 0

    for page_index in range(MAX_PAGES):
        # GBIF hard limit: offset + limit must be <= 100_000
        if offset + PAGE_SIZE > 100_000:
            print("Hit GBIF 100k search ceiling; stop.")
            break
        
        payload = fetch_page(offset)
        results = payload.get("results",[])
        path = save_page(payload, page_index)
        total_saved += len(results)

        print(
            f"page={page_index} offset={offset} "
            f"rows={len(results)} saved={path.name} "
            f"endOfRecords={payload.get('endOfRecords')}"
        )

        if payload.get("endOfRecords", True) or not results:       # not results: Empty page — stop even if flag is weird/missing
            break
        
        offset += PAGE_SIZE
        time.sleep(SLEEP_SECONDS)       # reduce 429 rate limits. Sleep after a successful page, before the next request (no need for 1st page)
     
    return total_saved

if __name__ == "__main__":
    n = extract()
    print(f"Done. Saved {n} occurrences rows to landing")
