<Alert status="info">
This data was generated from the <a href="https://gitlab.com/tanna.dev/dependency-management-data-example/">dependency-management-data-example project</a>, which gets updated every week on a Thursday.

```sql dmd_version
select
    value
from
    dmd.metadata
where
    name = 'dmd_version'
```

```sql finalised_at
select
    value
from
    dmd.metadata
where
    name = 'finalised_at'
```

<br>

The data has been produced by <code>dmd</code> <Value data={dmd_version} />, with a database finalised on <Value data={finalised_at} />.

Note that data sourced through Software Bills of Materials (SBOMs) is currently less frequently updated than Renovate data.

<LastRefreshed prefix="This view of the data was last sourced on" />
</Alert>
