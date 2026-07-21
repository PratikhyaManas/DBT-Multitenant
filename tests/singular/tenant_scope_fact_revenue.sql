-- Fails if fact_revenue contains records for tenants other than the execution tenant.
select *
from {{ ref('fact_revenue') }}
where tenant_id <> '{{ var("tenant_name", "default") }}'
