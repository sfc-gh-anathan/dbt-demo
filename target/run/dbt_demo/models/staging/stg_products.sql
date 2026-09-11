
  create or replace   view DBT_DEMO.RAW_staging.stg_products
  
   as (
    with source as (
    select * from DBT_DEMO.RAW.products
),

renamed as (
    select
        product_id,
        product_name,
        category,
        price as unit_price
    from source
)

select * from renamed
  );

