# Live Results

IACCDB supports a "live scoring" mode where partial results are displayed during an ongoing contest. This is controlled by the `busy_start` and `busy_end` date fields on a `Contest`.

## How live mode works

When the current date falls between `contests.busy_start` and `contests.busy_end`, the contest is in **live mode**. During this window, results are updated frequently as flights are completed and data is submitted.

Administrators set `busy_start` and `busy_end` via the contest edit form in the admin panel before the contest starts.

## Endpoints

### Get live results for a contest

```
GET /live_results/:id
```

Returns the current results for contest `:id`. Intended for display during a contest; updates as new JasPEr submissions arrive.

### Get last upload time

```
GET /last_upload/:id
```

Returns information about the most recent data submission for contest `:id`. Useful for polling to detect when new results have been posted.

**Response format:** HTML (timestamp and submission info)
