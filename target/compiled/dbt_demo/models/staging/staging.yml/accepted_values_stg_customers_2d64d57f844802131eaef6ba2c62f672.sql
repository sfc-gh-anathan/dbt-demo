
    
    

with all_values as (

    select
        country as value_field,
        count(*) as n_records

    from DBT_DEMO.RAW_staging.stg_customers
    group by country

)

select *
from all_values
where value_field not in (
    'USA','Canada','UK','Germany','France'
)


