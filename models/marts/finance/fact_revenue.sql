{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key=['tenant_id', 'revenue_month'],
    incremental_predicates=["DBT_INTERNAL_DEST.revenue_month >= dateadd(month, -2, current_date())"],
    schema=get_tenant_schema()
) }}

WITH new_data AS (
    SELECT 
        date_trunc('month', order_date) as revenue_month,
        tenant_id,
        SUM(amount) as total_revenue,
        COUNT(DISTINCT customer_id) as unique_customers
        FROM {{ ref('fact_orders') }}
    WHERE {{ tenant_filter() }}
    {% if is_incremental() %}
            AND order_date >= dateadd(day, -30, current_date())
    {% endif %}
    GROUP BY 1, 2
)

SELECT * FROM new_data