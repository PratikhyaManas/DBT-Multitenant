{% test no_cross_tenant_leakage(model, tenant_column='tenant_id') %}

select *
from {{ model }}
where {{ tenant_column }} <> '{{ var("tenant_name", "default") }}'

{% endtest %}
