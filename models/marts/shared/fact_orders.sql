{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['tenant_id', 'order_id'],
    schema=get_tenant_schema()
) }}

SELECT * FROM {{ source('raw', 'orders') }}
WHERE {{ tenant_filter() }}
{% if is_incremental() %}
  AND order_date >= dateadd(day, -14, current_date())
{% endif %}