# dbt-multitenant

Multi-tenant dbt starter project with tenant-aware schema routing, reusable tenant filters, and marts for shared, finance, HR, and marketing domains.

## What this repo includes

- Tenant-aware macros in `macros/tenant_macros.sql`
- Domain marts under `models/marts/`
- Source declarations and model tests
- Example multi-warehouse profile in `profiles_example.yml`
- Repo-local CI profile in `profiles/profiles.yml`
- GitHub Actions CI workflow for tenant-matrix execution

## Project structure

```text
macros/
  tenant_macros.sql
models/
  sources.yml
  marts/
    schema.yml
    shared/
      fact_orders.sql
    finance/
      fact_revenue.sql
    hr/
      employee_matrix.sql
    marketing/
      dim_campaigns.sql
dbt_project.yml
profiles/
  profiles.yml
profiles_example.yml
```

## Quick start

1. Install dependencies

```bash
pip install dbt-core dbt-databricks
dbt deps
```

1. (Optional) Copy profile to your local dbt profile location and update credentials

```bash
cp profiles_example.yml ~/.dbt/profiles.yml
```

1. Run for a tenant

```bash
dbt debug --target dev_databricks
dbt build --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}'
```

1. Or run with the repository profile (recommended for CI parity)

```bash
dbt debug --profiles-dir profiles --target dev_databricks
dbt parse --profiles-dir profiles --target dev_databricks
```

## How tenant isolation works

- `tenant_filter()` appends row-level filtering using `tenant_id`
- `get_tenant_schema()` creates per-tenant schemas like `analytics_tenant_a`
- Models are configured with `schema=get_tenant_schema()` so each tenant lands in its own schema

## Recommended run commands

Run all models for one tenant:

```bash
dbt run --target dev_databricks --vars '{"tenant_name": "tenant_a"}'
```

Run tests for one tenant:

```bash
dbt test --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}'
```

CI-parity run using repo profile:

```bash
dbt build --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}'
```

Run only tenant isolation singular tests:

```bash
dbt test --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select test_type:singular
```

Run only a domain:

```bash
dbt build --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select marts.finance+
```

## Notes

- Keep tenant IDs consistent with upstream source data (`raw.*` tables)
- Use a non-default tenant value in CI/CD and production runs
- For additional warehouses, add matching output blocks in `profiles.yml` and invoke the corresponding dbt target

## Custom test macros

- `no_cross_tenant_leakage`: fails if a model returns rows outside `var('tenant_name')`
- `positive_revenue_only`: fails if revenue in `fact_revenue.total_revenue` is less than or equal to zero

## End-to-end sample data engineering flow (HR, Finance, Marketing)

The repository includes sample raw inputs as seeds:

- `seeds/raw/orders.csv`
- `seeds/raw/employees.csv`
- `seeds/raw/campaigns.csv`

These are materialized into the `raw` schema so existing source references continue to work.

Run the complete demo pipeline for a tenant:

```bash
dbt deps --profiles-dir profiles
dbt seed --profiles-dir profiles --target dev_databricks --full-refresh
dbt build --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}'
```

Run each mart domain explicitly:

```bash
dbt run --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select marts.hr+
dbt run --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select marts.finance+
dbt run --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select marts.marketing+
```

Run tenant-scoped tests after build:

```bash
dbt test --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select test_type:generic
dbt test --profiles-dir profiles --target dev_databricks --vars '{"tenant_name": "tenant_a"}' --select test_type:singular
```
