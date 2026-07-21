{{ config(
    materialized='table',
    schema=get_tenant_schema(),
    contract={'enforced': true},
    tags=['semantic', 'bi', 'kpi']
) }}

with scorecard as (
    select
        tenant_id,
        revenue_month,
        total_revenue,
        revenue_per_customer,
        mom_revenue_growth,
        unique_customers,
        total_headcount,
        avg_salary_all_departments,
        avg_performance_all_departments,
        total_campaigns,
        total_marketing_budget,
        avg_campaign_budget,
        revenue_to_marketing_spend_ratio,
        revenue_per_employee
    from {{ ref('kpi_executive_scorecard') }}
    where {{ tenant_filter() }}
),

final as (
    select
        cast(tenant_id as string) as tenant_key,
        cast(revenue_month as date) as metric_month,
        cast(total_revenue as double) as finance_total_revenue,
        cast(revenue_per_customer as double) as finance_revenue_per_customer,
        cast(mom_revenue_growth as double) as finance_mom_revenue_growth,
        cast(unique_customers as bigint) as finance_unique_customers,
        cast(total_headcount as bigint) as hr_total_headcount,
        cast(avg_salary_all_departments as double) as hr_avg_salary,
        cast(avg_performance_all_departments as double) as hr_avg_performance,
        cast(total_campaigns as bigint) as marketing_total_campaigns,
        cast(total_marketing_budget as double) as marketing_total_budget,
        cast(avg_campaign_budget as double) as marketing_avg_campaign_budget,
        cast(revenue_to_marketing_spend_ratio as double) as efficiency_revenue_to_marketing_ratio,
        cast(revenue_per_employee as double) as efficiency_revenue_per_employee
    from scorecard
)

select *
from final
