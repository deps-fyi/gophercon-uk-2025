---
title: 2. Querying Data
---
OK, let's now see what data we've got.

<Alert status=info>
These queries are based on the example data, but if you're running them against your own repos, you'll have some different data (which may not match some of the commentary), but likely some of it will track with what's here.
</Alert>

## How much data do we have?

```sql num_renovate
select
    count(*)
from
    renovate
```

<!-- NOTE that the raw SBOMs (from Snyk) are many months old. SBOMs from GitHub are from 2025-07-27  -->

```sql num_sboms
select
    count(*)
from
    sboms
```

The Renovate datasource has <Value data={num_renovate} fmt=0,000 /> rows of dependency data vs the Software Bills of Materials (SBOMs) datasource has <Value data={num_sboms} />.

That's a bit of a difference in terms of number of rows, right?

## How many repos?

```sql num_renovate_repos
select
    count(*)
from
    (
        select
            distinct platform,
            organisation,
            repo
        from
            renovate
    )
```

There are currently <Value data={num_renovate_repos} /> repositories from Renovate.

## How many Components (for SBOMs)

```sql num_component_metadata
select
    count(distinct component_name)
from
    sboms;
```

There are currently <Value data={num_component_metadata} /> known SBOM components.

## What package metadata?

```sql num_renovate_package_types
select
    count(distinct package_type)
from
    renovate
```

```sql num_sbom_package_types
select
    count(distinct package_type)
from
    sboms
```

```sql top_10_packages_renovate
select
    package_name,
    package_type,
    count(*)
from
    renovate
group by
    package_name,
    package_type
order by
    count(*) desc
limit
    10
```

```sql top_10_packages_sbom
select
    package_name,
    package_type,
    count(*)
from
    sboms
group by
    package_name,
    package_type
order by
    count(*) desc
limit
    10
```

The Renovate datasource has <Value data={num_renovate_package_types} /> package types vs the Software Bills of Materials (SBOMs) datasource has <Value data={num_sbom_package_types} />.

<Grid cols=2>

<DataTable data={top_10_packages_renovate} title="Top 10 Renovate packages" />
<DataTable data={top_10_packages_sbom}     title="Top 10 SBOM packages" />

</Grid>

## Usage of unstable versions

```sql num_unstable
select
    distinct version
from
    renovate
where
    version like '0.%'
    or version like '0.%'
    or current_version like 'v0.%'
    or current_version like 'v0.%'
```

There are approximately <Value data={num_unstable} /> unstable versions in use.

```sql num_unstable_pie
select
    '# Unstable (v0)' as name,
    count(distinct version) as value
from
    renovate
where
    version like '0.%'
    or version like '0.%'
    or current_version like 'v0.%'
    or current_version like 'v0.%'
union
select
    '# stable' as name,
    count(distinct version) as value
from
    renovate
where
    version not like '0.%'
    and version not like '0.%'
    and current_version not like 'v0.%'
    and current_version not like 'v0.%'
```

This can also be seen more visually like so:

<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
        series: [
        {
          type: 'pie',
          data: [...num_unstable_pie],
        }
      ]
      }
    }
/>

## `oapi-codegen`

Where is [`oapi-codegen`](https://github.com/oapi-codegen/oapi-codegen) used?

(This is a little bit of a biased example, as Jamie is a Core Maintainer on [`oapi-codegen`](https://github.com/oapi-codegen/oapi-codegen))

```sql num_renovate_oapicodegen
select
    *
from
    renovate
where
    package_name = 'github.com/deepmap/oapi-codegen'
    or package_name = 'github.com/oapi-codegen/oapi-codegen'
    or package_name = 'github.com/oapi-codegen/oapi-codegen/v2'
```

```sql num_sbom_oapicodegen
select
    *
from
    sboms
where
    package_name = 'github.com/deepmap/oapi-codegen'
    or package_name = 'github.com/oapi-codegen/oapi-codegen'
    or package_name = 'github.com/oapi-codegen/oapi-codegen/v2'
```

<Grid cols=2>

<DataTable data={num_renovate_oapicodegen} />

<DataTable data={num_sbom_oapicodegen} />

</Grid>

Notice that it's found in Renovate data, but not in SBOMs.

## `golangci-lint`

```sql num_renovate_golangci_lint_all
select
    *
from
    renovate
where
    package_name like '%golangci-lint%'
```

```sql num_renovate_golangci_lint_go
select
    *
from
    renovate
where
    package_name = 'github.com/golangci/golangci-lint'
    or package_name = 'github.com/golangci/golangci-lint/v2'
```

```sql num_sbom_golangci_lint
select
    *
from
    sboms
where
    package_name like '%golangci-lint%'
```

<DataTable data={num_renovate_golangci_lint_all} title="golangci-lint (any references)" />

<DataTable data={num_renovate_golangci_lint_go} title="golangci-lint (Go module references)" />

<DataTable
  data={num_sbom_golangci_lint}
  emptySet=warn
/>

As above, it's present in Renovate data, but not SBOMs.

We can also surface cases where we're incorrectly source-tracking it (i.e. with `tools.go` or `go tool`) via query `dmd report golangCILint`, [example web app report](https://dependency-management-data-example.fly.dev/report/golangCILint).

## HTTP Frameworks

Standard library? Unfortunately no introspection 😥

But:

```sql renovate_usage_chi
select
    *
from
    renovate
where
    package_name = 'github.com/go-chi/chi'
    or package_name like 'github.com/go-chi/chi/v%'
```

<DataTable data={renovate_usage_chi} title="Chi (Renovate)") />

```sql sboms_usage_chi
select
    *
from
    sboms
where
    package_name = 'github.com/go-chi/chi'
    or package_name like 'github.com/go-chi/chi/v%'
```

<DataTable data={sboms_usage_chi} title="Chi (SBOMs)" />

```sql renovate_usage_gin
select
    *
from
    renovate
where
    package_name = 'github.com/gin-gonic/gin'
```

<DataTable data={renovate_usage_gin} title="Gin (Renovate)" />

```sql sboms_usage_gin
select
    *
from
    sboms
where
    package_name = 'github.com/gin-gonic/gin'
```

<DataTable data={sboms_usage_gin} title="Gin (SBOMs)" />

```sql renovate_usage_gorillamux
select
    *
from
    renovate
where
    package_name = 'github.com/gorilla/mux'
```

<DataTable data={renovate_usage_gorillamux} title="gorilla/mux (Renovate)" />

```sql sboms_usage_gorillamux
select
    *
from
    sboms
where
    package_name = 'github.com/gorilla/mux'
```

<DataTable data={sboms_usage_gorillamux} title="gorilla/mux (SBOMs)" />

```sql renovate_usage_fiber
select
    *
from
    renovate
where
    package_name = 'github.com/gofiber/fiber'
    or package_name like 'github.com/gofiber/fiber/v%'
```

<DataTable data={renovate_usage_fiber} title="Fiber (Renovate)" />

```sql sboms_usage_fiber
select
    *
from
    sboms
where
    package_name = 'github.com/gofiber/fiber'
    or package_name like 'github.com/gofiber/fiber/v%'
```

<DataTable data={sboms_usage_fiber} title="Fiber (SBOMs)" />

```sql renovate_usage_iris
select
    *
from
    renovate
where
    package_name = 'github.com/kataras/iris'
    or package_name like 'github.com/kataras/iris/v%'
```

<DataTable data={renovate_usage_iris} title="Iris (Renovate)" />

```sql renovate_usage_echo
select
    *
from
    renovate
where
    package_name = 'github.com/labstack/echo'
    or package_name like 'github.com/labstack/echo/v%'
```

<DataTable data={renovate_usage_echo} title="Echo (Renovate)"/>

```sql sboms_usage_echo
select
    *
from
    sboms
where
    package_name = 'github.com/labstack/echo'
    or package_name like 'github.com/labstack/echo/v%'
```

<DataTable data={sboms_usage_echo} title="Echo (SBOMs)" />

## Go versions

Now we've looked at plain data, let's look at more interesting metadata - versions of Go

[See this page](/2.1_go_versions/)

## `report dependenton`

It's also possible to use this report to flag a usage of a package.

(This needs some work, as it currently requires you know both `package_manager` and `package_type`)

For instance, usage of `oapi-codegen`:

- [`github.com/deepmap/oapi-codegen` (`package_type=golang`)](https://dependency-management-data-example.fly.dev/report/dependenton?packageName=github.com%2Fdeepmap%2Foapi-codegen&packageManager=golang&packageVersion=&packageCurrentVersion=)
- [`github.com/deepmap/oapi-codegen` (`package_manager=gomod`)](https://dependency-management-data-example.fly.dev/report/dependenton?packageName=github.com%2Fdeepmap%2Foapi-codegen&packageManager=gomod&packageVersion=&packageCurrentVersion=)
- (etc)

## Unwanted libraries

(Audience participation)

## Internal library digging

(Audience participation)

## Top Terraform modules

```sql top_10_terraform_modules_renovate
select
    package_name,
    count(*)
from
    renovate
where
    package_type = 'terraform'
group by
    package_name,
    package_type
order by
    count(*) desc
limit
    10
```

<DataTable data={top_10_terraform_modules_renovate} />

```sql top_10_terraform_modules_sboms
select
    package_name,
    count(*)
from
    sboms
where
    package_type = 'terraform'
group by
    package_name,
    package_type
order by
    count(*) desc
limit
    10
```

<DataTable
  data={top_10_terraform_modules_sboms}
  emptySet=warn
/>

## Top Go module dependencies

```sql top_10_go_modules_renovate
select
    package_name,
    dep_types,
    count(*)
from
    renovate
where
    package_type = 'golang'
group by
    package_name,
    package_type,
    dep_types
order by
    count(*) desc
limit
    10
```

<DataTable data={top_10_go_modules_renovate} />

```sql top_10_go_modules_direct_renovate
select
    package_name,
    count(*)
from
    renovate
where
    package_type = 'golang'
    and dep_types = '["require"]'
group by
    package_name,
    package_type,
    dep_types
order by
    count(*) desc
limit
    10
```

<DataTable data={top_10_go_modules_direct_renovate} />

```sql top_10_go_modules_indirect_renovate
select
    package_name,
    count(*)
from
    renovate
where
    package_type = 'golang'
    and dep_types = '["indirect"]'
group by
    package_name,
    package_type,
    dep_types
order by
    count(*) desc
limit
    10
```

<DataTable data={top_10_go_modules_indirect_renovate} />

## Specific outdated versions

"gin ... less than ..."

## General outdated data

(If used with `RENOVATE_DRY_RUN=lookup`, or `RG_INCLUDE_UPDATES=true`)

```sql num_outstanding_updates
select
    update_type,
    count(*)
from
    renovate_updates
group by
    update_type
order by
    (
        case
            when update_type == 'major' then 0
            when update_type == 'minor' then 1
            when update_type == 'patch' then 2
            when update_type == 'digest' then 3
            when update_type == 'replacement' then 5
            when update_type == 'pin' then 10
            when update_type == 'pinDigest' then 11
            else 500000
        end
    )
```

<DataTable data={num_outstanding_updates} />

<BarChart data={num_outstanding_updates} />

### For `golangci-lint`

```sql num_outdated_golangcilint
select
    update_type,
    count(*)
from
    renovate_updates
where
    package_name like '%golangci-lint%'
group by
    update_type
```
