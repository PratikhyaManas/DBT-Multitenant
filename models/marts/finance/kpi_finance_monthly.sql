{{ config(
    materialized='table',
    schema=get_tenant_schema(),
    tags=['finance', 'kpi']
) }}

with monthly_revenue as (
    select
        tenant_id,
        revenue_month,
        total_revenue,
        unique_customers,
        lag(total_revenue) over (
            partition by tenant_id
            order by revenue_month
        ) as previous_month_revenue
    from {{ ref('fact_revenue') }}
    where {{ tenant_filter() }}
),

final as (
    select
        tenant_id,
        revenue_month,
        total_revenue,
        unique_customers,
        case
            when unique_customers = 0 then null
            else total_revenue / unique_customers
        end as revenue_per_customer,
        case
            when previous_month_revenue is null or previous_month_revenue = 0 then null
            else (total_revenue - previous_month_revenue) / previous_month_revenue
        end as mom_revenue_growth
    from monthly_revenue
)

select *
from final
