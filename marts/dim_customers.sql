with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

products as (
    select * from {{ ref('stg_products') }}
),

order_totals as (
    select
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_status,
        sum(oi.quantity * p.unit_price) as order_total
    from orders o
    join order_items oi on o.order_id = oi.order_id
    join products p on oi.product_id = p.product_id
    group by 1, 2, 3, 4
),

customer_metrics as (
    select
        c.customer_id,
        c.full_name,
        c.email,
        c.country,
        c.customer_created_at,
        count(distinct ot.order_id) as total_orders,
        coalesce(sum(ot.order_total), 0) as lifetime_value,
        min(ot.order_date) as first_order_date,
        max(ot.order_date) as last_order_date
    from customers c
    left join order_totals ot on c.customer_id = ot.customer_id
    group by 1, 2, 3, 4, 5
)

select * from customer_metrics
