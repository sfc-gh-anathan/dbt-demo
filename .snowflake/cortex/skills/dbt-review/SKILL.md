---
name: dbt-review
description: >
  Review dbt models for best practices — naming conventions, ref() usage,
  schema tests, SQL style, and materializations. Use when asked to review,
  audit, or check a dbt model.
version: "1.0"
---

# dbt Model Review

Review dbt models for best practices when the user asks you to review, audit, or check a dbt model.

## What to check

1. **Naming conventions**
   - Staging models start with `stg_`
   - Dimension models start with `dim_`
   - Fact models start with `fct_`

2. **ref() usage**
   - All inter-model references use `{{ ref('model_name') }}`
   - No hardcoded database/schema/table names in models

3. **Schema tests**
   - Every model has a `.yml` entry with a description
   - Primary keys have `unique` and `not_null` tests
   - Foreign keys have `relationships` tests

4. **SQL style**
   - Uses CTEs instead of subqueries
   - One column per line in SELECT
   - Uppercase SQL keywords
   - Descriptive CTE names

5. **Materializations**
   - Staging models: `view` (lightweight, always fresh)
   - Mart models: `table` or `incremental` (performance)

## Output format

Present findings as a checklist:
- [x] Passing checks
- [ ] Issues found (with specific fix suggestions)
