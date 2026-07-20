{{ config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key=['tenant_id', 'employee_id'],
    schema=get_tenant_schema()
) }}

SELECT 
    employee_id,
    tenant_id,
    department,
    hire_date,
    salary,
    performance_score
FROM {{ source('raw', 'employees') }}
WHERE {{ tenant_filter() }}
{% if is_incremental() %}
  AND hire_date >= (SELECT MAX(hire_date) FROM {{ this }})
{% endif %}