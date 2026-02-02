with source as (
    select * from {{ source('raw', 'customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        email,
        country,
        created_at as customer_created_at
    from source
)

select * from renamed
