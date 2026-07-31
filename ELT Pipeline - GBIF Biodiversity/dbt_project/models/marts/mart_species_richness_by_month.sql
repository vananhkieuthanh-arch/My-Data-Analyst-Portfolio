with f as (
    select * from {{ ref('fct_occurrences') }}
)

select
    country_code,
    year,
    month,
    year_month_key,
    count(*) as observation_count,
    count(distinct taxon_key) as species_count
from f
group by country_code, year, month, year_month_key
order by year, month
