{{ config(
    materialized='table',
    schema=get_tenant_schema(),
    tags=['marketing', 'kpi']
) }}

with campaigns as (
    select
        tenant_id,
        channel,
        budget
    from {{ ref('dim_campaigns') }}
    where {{ tenant_filter() }}
),

final as (
    select
        tenant_id,
        channel,
        count(*) as campaigns_count,
        sum(budget) as total_budget,
        avg(budget) as avg_budget
    from campaigns
    group by 1, 2
)

select *
from final
