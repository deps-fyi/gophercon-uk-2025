---
title: 3. Using more data
---
Let's get some more data:

```sh
dmd db generate --db dmd.db advisories
dmd db generate --db dmd.db dependency-health
```

## Advisories

```sql advisories_breakdown
select
    advisory_type,
    level,
    count(*)
from
    advisories
group by
    advisory_type,
    level
order by
    (
        case
            advisory_type
            when 'SECURITY' then 0
            when 'UNMAINTAINED' then 1
            when 'DEPRECATED' then 2
            else 5
        end
    ),
    (
        case
            level
            when 'ERROR' then 0
            else 1
        end
    ),
    count(*) desc
```

<DataTable data={advisories_breakdown} />

### Advisories without end-of-life/deprecation dates

```sql advisories_without_dates_breakdown
select
    advisory_type,
    level,
    count(*)
from
    advisories
where
    (
        -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
        eol_from == '1970-01-01'
        or eol_from is null
    )
    and (
        -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
        supported_until == '1970-01-01'
        or supported_until is null
    )
group by
    advisory_type,
    level
order by
    (
        case
            advisory_type
            when 'SECURITY' then 0
            when 'UNMAINTAINED' then 1
            when 'DEPRECATED' then 2
            else 5
        end
    ),
    (
        case
            level
            when 'ERROR' then 0
            else 1
        end
    ),
    count(*) desc
```

<DataTable data={advisories_without_dates_breakdown} />

### Advisories with end-of-life/deprecation dates

```sql advisories_with_dates_breakdown
select
    advisory_type,
    level,
    count(*)
from
    advisories
where
    (
        -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
        eol_from != '1970-01-01'
        and eol_from is not null
    )
    and (
        -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
        supported_until != '1970-01-01'
        or supported_until is not null
    )
group by
    advisory_type,
    level
order by
    (
        case
            advisory_type
            when 'SECURITY' then 0
            when 'UNMAINTAINED' then 1
            when 'DEPRECATED' then 2
            else 5
        end
    ),
    (
        case
            level
            when 'ERROR' then 0
            else 1
        end
    ),
    count(*) desc
```

<DataTable data={advisories_with_dates_breakdown} />

### Already end-of-life

```sql already_eol
select
    advisories.organisation,
    advisories.repo,
    advisories.description,
    package_name,
    package_file_path,
from
    advisories
where
    -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
    eol_from != '1970-01-01'
    and
    -- is in the past
    date_diff('day', current_date, eol_from) <= 0
order by
    eol_from
```

<DataTable
    data={already_eol}
    emptySet="pass"
    emptyMessage="No known End-of-Life packages could be found"
/>

### Already deprecated

```sql already_deprecated
select
    advisories.organisation,
    advisories.repo,
    package_name,
    -- TODO: when advisory_type is available in Advisories
    -- package_type,
    package_manager,
    supported_until,
    eol_from,
    package_file_path,
from
    advisories
where
    -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
    supported_until != '1970-01-01'
    and
    -- is in past
    date_diff('day', current_date, supported_until) <= 0
order by
    supported_until
```

<DataTable
    data={already_deprecated}
    emptySet="pass"
    emptyMessage="No known deprecated packages could be found"
/>

### Upcoming end-of-life

```sql upcoming_eol
select
    advisories.organisation,
    advisories.repo,
    package_name,
    -- TODO: when advisory_type is available in Advisories
    -- package_type,
    eol_from,
    date_diff('day', current_date, eol_from) as '# days until End-of-Life',
    package_file_path,
from
    advisories
where
    -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
    eol_from != '1970-01-01'
    and
    -- is in the next 90 days
    (
        date_diff('day', current_date, eol_from) >= 0
        and date_diff('day', current_date, eol_from) <= 90
    )
order by
    eol_from
```

<DataTable data={upcoming_eol} />

## Use of deprecated/unmaintained dependencies

```sql num_deprecated_unmaintained
select
    (
        select
            count(*)
        from
            (
                select
                    distinct package_manager,
                    package_name
                from
                    renovate
            )
    ) as num_deps,
    (
        select
            count(*)
        from
            advisories
        where
            advisory_type = 'DEPRECATED'
    ) as total_deprecated,
    (
        select
            count(*)
        from
            advisories
        where
            advisory_type = 'UNMAINTAINED'
    ) as total_unmaintained
```

```sql num_deprecated_unmaintained_chart
select
    '# dependencies' as name,
    num_deps as value
from
    ${num_deprecated_unmaintained}
union
select
    '# deprecated' as name,
    total_deprecated as value
from
    ${num_deprecated_unmaintained}
union
select
    '# unmaintained' as name,
    total_unmaintained as value
from
    ${num_deprecated_unmaintained}
```

<!-- TODO: colours -->

<BarChart data={num_deprecated_unmaintained_chart} />

## Use of deprecated/unmaintained dependencies

```sql num_deprecated_unmaintained
select
    (
        select
            count(*)
        from
            (
                select
                    distinct package_manager,
                    package_name
                from
                    renovate
            )
    ) as num_deps,
    (
        select
            count(*)
        from
            advisories
        where
            advisory_type = 'DEPRECATED'
    ) as total_deprecated,
    (
        select
            count(*)
        from
            advisories
        where
            advisory_type = 'UNMAINTAINED'
    ) as total_unmaintained
```

```sql num_deprecated_unmaintained_chart
select
    '# dependencies' as name,
    num_deps as value
from
    ${num_deprecated_unmaintained}
union
select
    '# deprecated' as name,
    total_deprecated as value
from
    ${num_deprecated_unmaintained}
union
select
    '# unmaintained' as name,
    total_unmaintained as value
from
    ${num_deprecated_unmaintained}
```

<!-- TODO: colours -->

<BarChart data={num_deprecated_unmaintained_chart} />

### Use of deprecated/unmaintained dependencies (with age buckets)

```sql num_deprecated_unmaintained_buckets_by_support
select
    (
        case
            when (
                -- NOTE that in SQLite this is via `julianday`
                date_diff('day', current_date, supported_until)
            ) >= -90 then '~90d'
            when (
                date_diff('day', current_date, supported_until)
            ) >= -365 then '~1y'
            when (
                date_diff('day', current_date, supported_until)
            ) >= -(365 * 2) then '~2y'
            when (
                date_diff('day', current_date, supported_until)
            ) >= -(365 * 5) then '2-5y'
            when (
                date_diff('day', current_date, supported_until)
            ) <= -(365 * 5) then '>5y'
            else 'THIS SHOULD NOT BE HIT'
        end
    ) as bucket,
    sum (
        case
            when advisory_type = 'DEPRECATED' then 1
            else 0
        end
    ) as num_deprecated,
    sum (
        case
            when advisory_type = 'UNMAINTAINED' then 1
            else 0
        end
    ) as num_unmaintained
from
    advisories
where
    -- NOTE that DuckDB's SQL syntax (for Evidence) seems to default NULL date fields as the Unix epoch, so we need to ignore it like so:
    supported_until != '1970-01-01'
    -- make sure that we only have packages that are /currently/ past their support window, so this date is in the past
    and date_diff('day', current_date, supported_until) <= 0
group by
    bucket
order by
    (
        case
            when (
                date_diff('day', current_date, ANY_VALUE(supported_until))
            ) >= -90 then 0
            when (
                date_diff('day', current_date, ANY_VALUE(supported_until))
            ) >= -365 then 1
            when (
                date_diff('day', current_date, ANY_VALUE(supported_until))
            ) >= -(365 * 2) then 2
            when (
                date_diff('day', current_date, ANY_VALUE(supported_until))
            ) >= -(365 * 5) then 3
            when (
                date_diff('day', current_date, ANY_VALUE(supported_until))
            ) <= -(365 * 5) then 10
            else 'THIS SHOULD NOT BE HIT'
        end
    )
```

<BarChart data={num_deprecated_unmaintained_buckets_by_support} />

```sql num_deprecated_unmaintained_buckets_by_eol
select
    (
        case
            when (
                -- NOTE that in SQLite this is via `julianday`
                date_diff('day', current_date, eol_from)
            ) >= -90 then '~90d'
            when (
                date_diff('day', current_date, eol_from)
            ) >= -365 then '~1y'
            when (
                date_diff('day', current_date, eol_from)
            ) >= -(365 * 2) then '~2y'
            when (
                date_diff('day', current_date, eol_from)
            ) >= -(365 * 5) then '2-5y'
            when (
                date_diff('day', current_date, eol_from)
            ) <= -(365 * 5) then '>5y'
            else 'THIS SHOULD NOT BE HIT'
        end
    ) as bucket,
    sum (
        case
            when advisory_type = 'DEPRECATED' then 1
            else 0
        end
    ) as num_deprecated,
    sum (
        case
            when advisory_type = 'UNMAINTAINED' then 1
            else 0
        end
    ) as num_unmaintained
from
    advisories
where
    -- NOTE that DuckDB's SQL syntax (for Evidence) seems to parse this as **??**
    eol_from is not null
    and eol_from != '1970-01-01'
    -- make sure that we only have packages that are /currently/ past their support window, so this date is in the past
    and date_diff('day', current_date, eol_from) <= 0
group by
    bucket
order by
    (
        case
            when (
                date_diff('day', current_date, ANY_VALUE(eol_from))
            ) >= -90 then 0
            when (
                date_diff('day', current_date, ANY_VALUE(eol_from))
            ) >= -365 then 1
            when (
                date_diff('day', current_date, ANY_VALUE(eol_from))
            ) >= -(365 * 2) then 2
            when (
                date_diff('day', current_date, ANY_VALUE(eol_from))
            ) >= -(365 * 5) then 3
            when (
                date_diff('day', current_date, ANY_VALUE(eol_from))
            ) <= -(365 * 5) then 10
            else 'THIS SHOULD NOT BE HIT'
        end
    )
```

<BarChart data={num_deprecated_unmaintained_buckets_by_eol} />

## Dependencies that are in use, >5 years since planned deprecation/end-of-life

```sql using_but_5_years_past_deprecation_or_eol
select
    package_name,
    count(*),
    ANY_VALUE(advisory_type)
from
    advisories
where
    (
        supported_until != '1970-01-01'
        and abs(
            date_diff('day', current_date, supported_until)
        ) > (365 * 5)
    )
    or (
        eol_from != '1970-01-01'
        and abs(
            date_diff('day', current_date, eol_from)
        ) > (365 * 5)
    )
group by
    package_name
order by
    count(*) desc
```

<DataTable data={using_but_5_years_past_deprecation_or_eol} />

## Use of dependencies which are no longer maintained

```sql using_but_deprecated_or_eol
select
    -- eol_from,
    -- abs(cast ((julianday(eol_from) - julianday('now')) as integer)),
    package_name,
    (
        case
            when abs(
                date_diff('day', current_date, eol_from)
            ) > (365 * 5) then 'UNMAINTAINED'
            when abs(
                date_diff('day', current_date, supported_until)
            ) > (365 * 5) then 'DEPRECATED'
            else 'THIS SHOULD NOT BE HIT'
        end
    ) as bucket,
    count(*)
from
    advisories
where
    (
        supported_until != '1970-01-01'
        and abs(
            date_diff('day', current_date, supported_until)
        ) > (365 * 5)
    )
    or (
        eol_from != '1970-01-01'
        and abs(
            date_diff('day', current_date, eol_from)
        ) > (365 * 5)
    )
group by
    package_name,
    bucket
order by
    count(*) desc,
    package_name,
    bucket
```

<DataTable data={using_but_deprecated_or_eol} />

## Use of dependencies which seem not actively maintained

```sql seems_unmaintained
select
    package_type,
    count(*)
from
    (
        select
            distinct renovate.package_name,
            renovate.package_type
        from
            renovate
            inner join dependency_health on renovate.package_name = dependency_health.package_name
            and renovate.package_type = dependency_health.package_type
        where
            (scorecard_maintained <= 5)
    )
group by
    package_type
order by
    count(*) desc
limit
    7
```

<BarChart
    data={seems_unmaintained}
/>

## Use of dependencies which seem not actively maintained (and are looking for funding)

```sql seems_unmaintained_and_looking_funding
select
    package_type,
    count(*)
from
    (
        select
            distinct renovate.package_name,
            renovate.package_type
        from
            renovate
            inner join dependency_health on renovate.package_name = dependency_health.package_name
            and renovate.package_type = dependency_health.package_type
        where
            -- actively/seemingly unmaintained
            (
                (scorecard_maintained <= 5)
                or (
                    scorecard_maintained == 0
                    or ecosystems_repo_archived == true
                )
            )
            and
            -- looking for funding
            (ecosystems_funding is not null)
    )
group by
    package_type
order by
    count(*) desc
limit
    7
```

<BarChart
    data={seems_unmaintained_and_looking_funding}
/>
