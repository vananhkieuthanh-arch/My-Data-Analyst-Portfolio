with occ as (
    select * from {{ ref('stg_gbif__occurrences') }}
),

deduped as (
    select
        taxon_key,
        max(scientific_name) as scientific_name,
        max(kingdom) as kingdom, 
        max(phylum) as phylum, 
        max(class) as class, 
        max(order_name) as order_name, 
        max(family) as family, 
        max(genus) as genus, 
        max(species) as species
    from occ
    where taxon_key is not null
    group by taxon_key
)

select * from deduped