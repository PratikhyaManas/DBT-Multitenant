{{ config(
    materialized='incremental',
    schema=get_tenant_schema()
) }}

SELECT
    date_trunc('month', order_date) as revenue_month,
    tenant_id,
    SUM(amount) as total_revenue,
    COUNT(DISTINCT customer_id) as unique_customers
FROM {{ ref('fct_orders') }}
WHERE {{ tenant_filter() }}
GROUP BY 1, 2
