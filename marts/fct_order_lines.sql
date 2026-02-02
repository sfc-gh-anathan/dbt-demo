with orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

final as (
    select
        oi.order_item_id,
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status,
        oi.product_id,
        p.product_name,
        p.category,
        oi.quantity,
        p.unit_price,
        oi.quantity * p.unit_price as line_total
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join products p on oi.product_id = p.product_id
)

select * from final
