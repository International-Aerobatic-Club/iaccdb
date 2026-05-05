# Manny

**Manny** is a legacy external system from which IACCDB can retrieve contest data. This path is used for older contests or situations where JasPEr XML is not available.

## How it works

1. An administrator navigates to **Admin → Manny List** to see contests available from the Manny system.
2. The admin triggers a retrieval for a specific Manny number via **Admin → Manny Synchs → Retrieve**.
3. IACCDB enqueues a `RetrieveMannyJob` background job.
4. The job downloads the Manny-format data, parses it via `Manny::Parse`, and imports it to the database via `Manny::MannyToDB`.
5. The same downstream computation jobs run as for JasPEr: flights, judge metrics, pilot rollups, and annual series.

## Database records

Each Manny retrieval creates a `MannySynch` record linking the contest to its Manny number and synch date.

## Status

The Manny path is considered legacy. New contests should use [JasPEr XML](jasper.md) submission.
