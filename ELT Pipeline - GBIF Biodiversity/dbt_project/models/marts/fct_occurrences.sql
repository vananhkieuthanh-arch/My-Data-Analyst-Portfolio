with occ as (
    select * from {{ ref('stg_gbif__occurrences') }}
),

buckets as (
    select 
        country_code,
        round(latitude::numeric, 2) as lat_bucket, 
        round(longitude::numeric, 2) as lon_bucket
    from occ
)

select
    gbif_key, 
    taxon_key, 
    dataset_key,
    year,
    month,
    (year * 100 + month) as year_month_key,
    country_code,
    round(latitude::numeric, 2) as lat_bucket, 
    round(longitude::numeric, 2) as lon_bucket,
    country_code
        || '|'
        || round(occ.latitude::numeric, 2)::text
        || '|'
        || round(occ.longitude::numeric, 2)::text as location_key,
    ingested_at,
    event_date,
    1 as occurrence_count
from occ