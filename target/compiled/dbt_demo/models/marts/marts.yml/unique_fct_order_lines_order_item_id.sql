
    
    

select
    order_item_id as unique_field,
    count(*) as n_records

from DBT_DEMO.RAW_marts.fct_order_lines
where order_item_id is not null
group by order_item_id
having count(*) > 1


