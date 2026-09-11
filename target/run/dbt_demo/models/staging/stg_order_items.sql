
  create or replace   view DBT_DEMO.RAW_staging.stg_order_items
  
   as (
    with source as (
    select * from DBT_DEMO.RAW.order_items
),

renamed as (
    select
        order_item_id,
        order_id,
        product_id,
        quantity
    from source
)

select * from renamed
  );

