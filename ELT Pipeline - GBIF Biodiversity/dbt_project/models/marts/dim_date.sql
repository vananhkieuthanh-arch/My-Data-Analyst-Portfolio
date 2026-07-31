with occ as (
    select distinct 
        year, month
    from {{ ref('stg_gbif__occurrences') }}
    where year is not null
        and month is not null
)

select 
    year, 
    month, 
    -- surrogate-ish key for joins
    (year * 100 + month) as year_month_key
from occ