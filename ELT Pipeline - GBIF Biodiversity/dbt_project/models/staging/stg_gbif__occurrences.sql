with source as (
    select * from {{ source('raw', 'gbif_occurrences') }}
),

renamed as (
    select
        gbif_key, 
        scientific_name,
        taxon_key, 
        kingdom, 
        phylum, 
        class, 
        order_name, 
        family, 
        genus, 
        species, 
        country_code,
        decimal_latitude as latitude, 
        decimal_longitude as longitude, 
        event_date, 
        year, 
        month, 
        dataset_key, 
        basis_of_record, 
        ingested_at
    from source
    where decimal_latitude is not null 
        and decimal_longitude is not null
)

select * from renamed