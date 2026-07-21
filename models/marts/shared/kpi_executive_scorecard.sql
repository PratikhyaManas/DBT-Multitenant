{{ config(
    materialized='table',
    schema=get_tenant_schema(),
    contract={'enforced': true},
    tags=['executive', 'kpi']
) }}

with finance as (
    select
        tenant_id,
        revenue_month,
        total_revenue,
        revenue_per_customer,
        mom_revenue_growth,
        unique_customers
    from {{ ref('kpi_finance_monthly') }}
    where {{ tenant_filter() }}
),

hr as (
    select
        tenant_id,
        sum(headcount) as total_headcount,
        avg(avg_salary) as avg_salary_all_departments,
        avg(avg_performance_score) as avg_performance_all_departments
    from {{ ref('kpi_hr_workforce') }}
    where {{ tenant_filter() }}
    group by 1
),

marketing as (
    select
        tenant_id,
        sum(campaigns_count) as total_campaigns,
        sum(total_budget) as total_marketing_budget,
        avg(avg_budget) as avg_campaign_budget
    from {{ ref('kpi_marketing_channel') }}
    where {{ tenant_filter() }}
    group by 1
),

final as (
    select
        cast(f.tenant_id as string) as tenant_id,
        cast(f.revenue_month as date) as revenue_month,
        cast(f.total_revenue as double) as total_revenue,
        cast(f.revenue_per_customer as double) as revenue_per_customer,
        cast(f.mom_revenue_growth as double) as mom_revenue_growth,
        cast(f.unique_customers as bigint) as unique_customers,
        cast(h.total_headcount as bigint) as total_headcount,
        cast(h.avg_salary_all_departments as double) as avg_salary_all_departments,
        cast(h.avg_performance_all_departments as double) as avg_performance_all_departments,
        cast(m.total_campaigns as bigint) as total_campaigns,
        cast(m.total_marketing_budget as double) as total_marketing_budget,
        cast(m.avg_campaign_budget as double) as avg_campaign_budget,
        case
            when m.total_marketing_budget = 0 then null
            else cast(f.total_revenue / m.total_marketing_budget as double)
        end as revenue_to_marketing_spend_ratio,
        case
            when h.total_headcount = 0 then null
            else cast(f.total_revenue / h.total_headcount as double)
        end as revenue_per_employee
    from finance f
    left join hr h
        on f.tenant_id = h.tenant_id
    left join marketing m
        on f.tenant_id = m.tenant_id
)

select *
from final
