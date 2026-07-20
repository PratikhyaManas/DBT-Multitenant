{{ config(
    materialized='table',
    schema=get_tenant_schema()
) }}

SELECT
    campaign_id,
    tenant_id,
    campaign_name,
    channel,
    start_date,
    budget
FROM {{ source('raw', 'campaigns') }}
WHERE {{ tenant_filter() }}
