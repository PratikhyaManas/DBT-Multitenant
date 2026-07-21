-- Fails if fact_orders contains records for tenants other than the execution tenant.
select *
from {{ ref('fact_orders') }}
where tenant_id <> '{{ var("tenant_name", "default") }}'
