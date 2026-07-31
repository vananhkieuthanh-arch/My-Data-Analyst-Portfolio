import requests
import json
from pathlib import Path
from datetime import date

# Layer A — Match taxon name & its key
    # r = requests.get("https://api.gbif.org/v1/species/match",
    #                  params={"name": "Aves"},
    #                  timeout=30,
    #                  )
    # r.raise_for_status()
    # data = r.json()
    # print(data)
    # print("usageKey:", data.get("usageKey"))

#Layer B — Fetch one occurrence page, choose 1 country - VN
TAXON_KEY = 212   # Confirm from Layer A

params = {
    "country": "VN",
    "taxonKey": TAXON_KEY, 
    "hasCoordinate": "true",
    "year": 2023,
    "limit": 5,
    "offset": 0,}

r = requests.get("https://api.gbif.org/v1/occurrence/search",
                 params=params,
                 timeout=60,
                )
r.raise_for_status()
payload = r.json()

    # print("keys:", payload.keys())    # See the column name
    # print("count:", payload.get("count"))    # How big the total record is
    # print("endOfRecords:", payload.get("endOfRecords"))    #  Learn the stop condition for pagination
    # print("results on this page:", len(payload.get("results",[])))    # Return number of actual records extracted 

# Layer C — Inspect one record’s fields --> From this you decide what to store in bronze.
    # first = payload["results"][0]
    # print(json.dumps(first, indent=2)[:2000]) # first ~2000 chars
    # print("\nField names:", sorted(first.keys()))

# Layer D — Save the page to landing
ROOT = Path(__file__).resolve().parents[1]    # .resolve() = absolute path
out_dir = ROOT / "data" / "landing" / "occurrences" / f"explore_gbif_dt={date.today().isoformat()}"
out_dir.mkdir(parents=True, exist_ok=True)    # create missing parents (data, landing, etc.)

out_file = out_dir / "page_0000.json"
out_file.write_text(json.dumps(payload, indent=2), encoding="utf-8")    # write_text(..., encoding="utf-8") = save as a text file
print("Saved:", out_file)
