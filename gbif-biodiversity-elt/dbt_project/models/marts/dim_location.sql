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
    country_code,
    lat_bucket, 
    lon_bucket,
    CONCAT(country_code, '|', lat_bucket, '|', lon_bucket) as location_key
from buckets