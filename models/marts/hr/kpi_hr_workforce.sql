{{ config(
    materialized='table',
    schema=get_tenant_schema(),
    tags=['hr', 'kpi']
) }}

with base as (
    select
        tenant_id,
        department,
        salary,
        performance_score,
        hire_date
    from {{ ref('employee_matrix') }}
    where {{ tenant_filter() }}
),

final as (
    select
        tenant_id,
        department,
        count(*) as headcount,
        avg(salary) as avg_salary,
        avg(performance_score) as avg_performance_score,
        min(hire_date) as earliest_hire_date,
        max(hire_date) as latest_hire_date
    from base
    group by 1, 2
)

select *
from final
