{% macro tenant_filter() %}
  {% set tenant = var('tenant_name', 'default') | string %}
  tenant_id = '{{ tenant }}'
{% endmacro %}

{% macro get_tenant_schema(base_schema=none, tenant_name=none) %}
  {% set base = base_schema or target.schema %}
  {% set tenant = tenant_name or var('tenant_name', 'default') | lower | replace(' ', '_') %}
  {{ base }}_{{ tenant }}
{% endmacro %}

{# Databricks-specific #}
{% macro databricks_tenant_schema(tenant) %}
  {{ target.catalog }}.{{ get_tenant_schema(tenant_name=tenant) }}
{% endmacro %}
