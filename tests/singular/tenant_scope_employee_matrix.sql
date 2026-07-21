-- Fails if employee_matrix contains records for tenants other than the execution tenant.
select *
from {{ ref('employee_matrix') }}
where tenant_id <> '{{ var("tenant_name", "default") }}'
