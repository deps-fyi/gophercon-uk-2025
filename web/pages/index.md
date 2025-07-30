---
title: Dependency Management Data @ Manchester Gophers 2025
---
A presentation of (some of) the data that will be explored as part of the [July Manchester Gophers workshop](https://www.meetup.com/go-mcr/events/309017083/) by [Jamie Tanna](https://www.jvt.me).

<img class=markdown alt="The Manchester Gophers logo, a gopher with wings" src="https://manchestergophers.com/static/images/manchester-gopher-logo-no-text.webp" style="width: 30%" />

This web application provides insights into the [dependency-management-data](https://dmd.tanna.dev) project's [example data](https://gitlab.com/tanna.dev/dependency-management-data-example/).

This uses [Evidence](https://evidence.dev/) to provide a set of visualisations on top of the underlying SQLite database.

A number of queries are provided here for an idea of interesting things you can do with the data, but there will likely be some organisation-specific things you can think of, based on this data!

This is an additional set of insights you can get on top of the [deployment of the `dmd-web` CLI tool for the example data](https://dependency-management-data-example.fly.dev/).

This project, like Dependency Management Data's example project, is Open Source and can be found [on GitLab.com](https://gitlab.com/tanna.dev/dependency-management-data-example-insights).

{@partial "meta.md"}

```sql meta
select
    (
        select
            count(distinct platform)
        from
            renovate
    ) as num_platforms,
    (
        select
            count(distinct organisation)
        from
            renovate
    ) as num_organisations,
    (
        select
            count(distinct repo)
        from
            renovate
    ) as num_repos,
    (
        select
            count(*)
        from
            renovate
    ) as num_renovate_rows,
    (
        select
            count(*)
        from
            sboms
    ) as num_sbom_rows
```

This database contains data from <Value data={meta} column=num_platforms /> platforms, <Value data={meta} column=num_organisations /> organisations, and <Value data={meta} column=num_repos /> repos, over <Value data={meta} column=num_renovate_rows fmt=num0 /> rows of dependencies derived from [renovate-graph](https://www.npmjs.com/package/@jamietanna/renovate-graph) data, and <Value data={meta} column=num_sbom_rows fmt=num0 /> rows of dependencies derived from Software Bills of Materials.

```sql deps_per_repo
select
    distinct platform || '/' || organisation || '/' || repo as name,
    count(*) as value
from
    renovate
group by
    platform,
    organisation,
    repo
order by
    count(*) desc
limit
    10
```

The largest 10 repos (based on number of dependencies are:

<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
        series: [
        {
          type: 'pie',
          data: [...deps_per_repo],
        }
      ]
      }
    }
/>




```sql deps_per_package_ecosystem
select
    distinct package_type as name,
    count(*) as value
from
    renovate
    -- TODO: https://gitlab.com/tanna.dev/dependency-management-data/-/issues/653
where
    dep_types not like '%"missing-data"%'
group by
    package_type
order by
    count(*) desc
limit
    20
```

The top 20 package ecosystems are:

<ECharts config={
    {
        tooltip: {
            formatter: '{b}: {c} ({d}%)'
        },
        series: [
        {
          type: 'pie',
          data: [...deps_per_package_ecosystem],
        }
      ]
      }
    }
/>
