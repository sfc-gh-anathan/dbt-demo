# dbt Demo Guide for Beginners

**Duration:** 30 minutes  
**Audience:** Client learning dbt for the first time  
**Environment:** Snowflake + dbt Core (Workspaces)

---

## Pre-Demo Setup Checklist

- [ ] Mock data created in `DBT_DEMO.RAW` (customers, products, orders, order_items)
- [ ] dbt project files in `~/Documents/code/dbt_client_demo/`
- [ ] Snowsight open in browser
- [ ] Git repository created (optional but recommended for demo)

---

## Part 1: What is dbt? (10 minutes)

### Topic 1: Introduction to dbt
**Say:** "dbt stands for 'data build tool'. It's the T in ELT - it transforms raw data into analytics-ready models using just SQL."

**Show:** Open any slide or diagram showing ELT pipeline.

---

### Topic 2: Models
**Say:** "In dbt, a model is just a SQL SELECT statement saved as a `.sql` file. dbt turns it into a table or view in your warehouse."

**Click:** Open `models/staging/stg_customers.sql`

**Point out:**
- It's just SQL - nothing proprietary
- The `with` pattern (CTEs) is common
- Notice `{{ source('raw', 'customers') }}` - we'll explain that next

```sql
-- Highlight this section:
select
    customer_id,
    first_name || ' ' || last_name as full_name,  -- Simple transformation
    email,
    country
from source
```

---

### Topic 3: Materialization
**Say:** "dbt can create views, tables, or incremental tables from your models. You configure this in the model or project file."

**Click:** Open `dbt_project.yml`

**Point out:**
```yaml
models:
  dbt_demo:
    staging:
      +materialized: view      # <-- Staging models become VIEWS
    marts:
      +materialized: table     # <-- Mart models become TABLES
```

**Say:** "Staging as views = fast, no storage cost. Marts as tables = optimized for querying."

---

### Topic 4: Sources
**Say:** "Sources declare your raw data tables. This gives you lineage tracking and freshness monitoring."

**Click:** Open `models/staging/sources.yml`

**Point out:**
```yaml
sources:
  - name: raw
    database: DBT_DEMO
    schema: RAW
    tables:
      - name: customers
        description: "Customer master data"  # <-- Documentation!
```

**Say:** "Now we can reference this as `{{ source('raw', 'customers') }}` anywhere in our project."

---

### Topic 5: Refs and the DAG
**Say:** "This is the magic of dbt. When you reference another model with `ref()`, dbt builds a dependency graph automatically."

**Click:** Open `models/marts/dim_customers.sql`

**Point out:**
```sql
with customers as (
    select * from {{ ref('stg_customers') }}  -- <-- ref() creates dependency
),
orders as (
    select * from {{ ref('stg_orders') }}     -- <-- Another dependency
),
```

**Say:** "dbt now knows: to build `dim_customers`, it must first build `stg_customers` and `stg_orders`. This is the DAG - Directed Acyclic Graph."

---

### Topic 6: Layered Architecture (Staging → Marts)
**Say:** "Best practice is to organize models in layers:"

**Draw or show:**
```
RAW DATA (sources.yml)
    ↓
STAGING (stg_*) - Clean, rename, cast. Views.
    ↓
MARTS (dim_*, fct_*) - Business logic, joins. Tables.
    ↓
ANALYSTS & DASHBOARDS
```

**Point out folder structure:**
```
models/
├── staging/          # One-to-one with source tables
│   ├── stg_customers.sql
│   ├── stg_orders.sql
│   └── sources.yml
└── marts/            # Business-level models
    ├── dim_customers.sql
    └── fct_order_lines.sql
```

---

### Topic 7: Tests
**Say:** "dbt has built-in data quality tests. You define them in YAML."

**Click:** Open `models/staging/staging.yml`

**Point out:**
```yaml
- name: customer_id
  tests:
    - unique        # No duplicates allowed
    - not_null      # Must have a value

- name: country
  tests:
    - accepted_values:
        values: ['USA', 'Canada', 'UK', 'Germany', 'France']

- name: customer_id
  tests:
    - relationships:            # Foreign key check!
        to: ref('stg_customers')
        field: customer_id
```

**Say:** "These run automatically and fail your pipeline if data quality issues exist."

---

### Topic 8: Documentation
**Say:** "Every column can have a description. dbt generates a documentation website from this."

**Point out the `description` fields in the YAML files.**

---

## Part 2: Snowflake Workspaces UI (10 minutes)

### Topic 9: Opening Workspaces
**Click:** Snowsight → **Projects** → **Workspaces**

**Say:** "Workspaces is Snowflake's built-in IDE for dbt. No local setup needed."

**Click:** Create new workspace or open existing one

---

### Topic 10: Git Integration
**Click:** In workspace, click the **Git** icon or **Repository** settings

**Say:** "You can connect any Git repository - GitHub, GitLab, Bitbucket. All changes are version-controlled."

**Show:**
- How to connect a repo
- Branch selector
- Commit button
- Pull/Push

**Say:** "Your dbt project lives in Git. Snowflake pulls it in when you deploy."

---

### Topic 11: File Explorer
**Click:** Show the left sidebar file tree

**Point out:**
- `dbt_project.yml` at root
- `models/` folder with subfolders
- `profiles.yml` for connection settings

**Say:** "This is the same structure you'd have locally. You can edit files right here."

---

### Topic 12: Running dbt from the UI
**Click:** Terminal or command palette in workspace

**Type:** `dbt run`

**Say:** "This builds all your models. Watch the output - it shows each model being created."

**Then type:** `dbt test`

**Say:** "This runs all data quality tests. Green means pass, red means data issues."

---

### Topic 13: Lineage Visualization
**Click:** The **Lineage** tab or DAG viewer in the workspace

**Say:** "This is the visual DAG. You can see how data flows from sources through staging to marts."

**Point out:**
- Source nodes (green)
- Model nodes (blue)
- Arrows showing dependencies
- Click a node to see details

---

### Topic 14: DBT PROJECT Object
**Say:** "When you're ready to deploy, Snowflake creates a `DBT PROJECT` object - a versioned, executable package."

**Show SQL:**
```sql
-- Creating a dbt project object
CREATE DBT PROJECT my_demo_project
  FROM 'snow://workspace/my_workspace';

-- View existing projects
SHOW DBT PROJECTS;
```

**Say:** "Each deployment creates a new version. You can roll back if needed."

---

## Part 3: Operations & Scheduling (10 minutes)

### Topic 15: Deploy via Snowflake CLI
**Say:** "For CI/CD, you use the Snowflake CLI to deploy from your Git repo."

**Show command:**
```bash
snow dbt deploy \
  --project-dir ./dbt_client_demo \
  --database DBT_DEMO \
  --schema ANALYTICS
```

---

### Topic 16: Execute via SQL
**Say:** "Once deployed, you can run the project with a simple SQL command."

**Show SQL:**
```sql
EXECUTE DBT PROJECT my_demo_project
  ARGS = 'run'
  WAREHOUSE = 'DAILY_WH_XS';
```

**Say:** "This runs inside Snowflake - no external compute needed."

---

### Topic 17: Scheduling with Tasks
**Say:** "Schedule dbt runs using Snowflake Tasks - no external orchestrator required."

**Show SQL:**
```sql
CREATE TASK run_dbt_daily
  WAREHOUSE = 'DAILY_WH_XS'
  SCHEDULE = 'USING CRON 0 6 * * * America/New_York'
AS
  EXECUTE DBT PROJECT my_demo_project ARGS = 'run';

ALTER TASK run_dbt_daily RESUME;
```

---

### Topic 18: CI/CD Integration
**Say:** "For production, integrate with GitHub Actions or Azure DevOps."

**Show concept:**
```yaml
# .github/workflows/dbt-deploy.yml
on:
  push:
    branches: [main]
jobs:
  deploy:
    steps:
      - run: snow dbt deploy
      - run: snow dbt execute --args "run"
```

---

### Topic 19: Monitoring
**Click:** Snowsight → **Monitoring** → **Query History**

**Say:** "Filter by 'DBT' to see all dbt executions. You get full query history, timing, and errors."

**Also show:**
- Task history (if using scheduled tasks)
- Execution logs

---

### Topic 20: Access Control
**Say:** "dbt projects need the right permissions."

**Show SQL:**
```sql
-- Grant dbt role access to source data
GRANT USAGE ON DATABASE DBT_DEMO TO ROLE DBT_ROLE;
GRANT USAGE ON SCHEMA DBT_DEMO.RAW TO ROLE DBT_ROLE;
GRANT SELECT ON ALL TABLES IN SCHEMA DBT_DEMO.RAW TO ROLE DBT_ROLE;

-- Grant ability to create models
GRANT CREATE TABLE ON SCHEMA DBT_DEMO.MARTS TO ROLE DBT_ROLE;
GRANT CREATE VIEW ON SCHEMA DBT_DEMO.STAGING TO ROLE DBT_ROLE;
```

---

## Demo Wrap-Up

**Say:** "To summarize what we covered:"

1. **dbt transforms data** using SQL models
2. **Layers** (staging → marts) keep things organized  
3. **Tests and docs** ensure quality and understanding
4. **Snowflake Workspaces** provides a built-in IDE with Git
5. **Tasks** schedule runs natively in Snowflake
6. **No external tools needed** - it all runs inside Snowflake

**Ask:** "What questions do you have?"

---

## Quick Reference

| Command | What it does |
|---------|--------------|
| `dbt run` | Build all models |
| `dbt run --select stg_customers` | Build one model |
| `dbt test` | Run all tests |
| `dbt build` | Run + test in order |
| `dbt docs generate` | Create documentation |

---

## Files in This Demo

```
~/Documents/code/dbt_client_demo/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # Snowflake connection
└── models/
    ├── staging/
    │   ├── sources.yml      # Source definitions
    │   ├── staging.yml      # Tests & docs for staging
    │   ├── stg_customers.sql
    │   ├── stg_products.sql
    │   ├── stg_orders.sql
    │   └── stg_order_items.sql
    └── marts/
        ├── marts.yml        # Tests & docs for marts
        ├── dim_customers.sql
        └── fct_order_lines.sql
```

**Snowflake Objects Created:**
- Database: `DBT_DEMO`
- Schemas: `RAW`, `STAGING`, `MARTS`
- Raw tables: `CUSTOMERS`, `PRODUCTS`, `ORDERS`, `ORDER_ITEMS`
