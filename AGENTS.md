# AGENTS.md — dbt-demo Team Standards

## Project Context
This is a dbt project for the DBT_DEMO database. Source data lives in `DBT_DEMO.RAW` and models
are materialized into `DBT_DEMO.PUBLIC`. The warehouse is `DAILY_WH_XS`.

## Safety Guardrails
- **Never run destructive SQL without explicit confirmation.** Always ask before DROP, TRUNCATE, DELETE, or REPLACE.
- **Never overwrite existing files without asking.** Confirm before modifying any .sql model, .yml schema, or config file.
- **Always run `dbt build` after model changes** to validate that tests pass before considering work complete.

## dbt Conventions
- Use **staging models** (`stg_`) for light transformations on source data (renaming, casting, filtering).
- Use **mart models** (`dim_`, `fct_`) for business-level entities and facts.
- Every model must have a corresponding entry in a `.yml` schema file with at least a description and primary key test.
- Use CTEs instead of subqueries. Name CTEs descriptively (e.g., `active_customers`, not `cte1`).
- Use `ref()` for all inter-model references. Never use hardcoded table names in models.

## SQL Style
- Uppercase SQL keywords (`SELECT`, `FROM`, `WHERE`, `JOIN`).
- Lowercase column names and aliases using snake_case.
- One column per line in SELECT statements.
- Always qualify ambiguous columns with the table/CTE alias.
