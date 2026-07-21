{% test positive_revenue_only(model, revenue_column='total_revenue') %}

select *
from {{ model }}
where {{ revenue_column }} <= 0

{% endtest %}
