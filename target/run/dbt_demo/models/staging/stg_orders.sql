
  create or replace   view DBT_DEMO.RAW_staging.stg_orders
  
   as (
    with source as (
    select * from DBT_DEMO.RAW.orders
),

renamed as (
    select
        order_id,
        customer_id,
        order_date,
        status as order_status
    from source
)

select * from renamed
  );

