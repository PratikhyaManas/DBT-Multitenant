-- Fails if dim_campaigns contains records for tenants other than the execution tenant.
select *
from {{ ref('dim_campaigns') }}
where tenant_id <> '{{ var("tenant_name", "default") }}'
