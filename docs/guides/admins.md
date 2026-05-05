# For Administrators

This guide covers the admin panel tasks for maintaining IACCDB data quality.

## Accessing the admin panel

Navigate to `https://iaccdb.iac.org/admin` and log in with the `contest_admin` credentials from `config/admin.yml`.

## Monitoring submissions

**Admin → Data Posts** lists every JasPEr XML submission received, with status flags:

| Flag | Meaning |
|---|---|
| `is_integrated` | Processing completed successfully |
| `has_error` | An error occurred during processing |
| `is_obsolete` | A newer submission supersedes this one |

For any submission, click **Show** to see the full error description. Click **Download** to retrieve the original XML. Click **Resubmit** to re-enqueue processing (useful after fixing a bug).

## Monitoring the job queue

**Admin → Queues** shows the delayed_job background job queue. Use this to verify that jobs are running and to diagnose stuck or failed jobs.

## Viewing processing failures

**Admin → Failures** shows detailed error records from failed processing steps. Each failure records the step name, contest, and error description. This is more granular than `data_posts` — a single submission can produce multiple failure records if processing partially succeeded.

## Recomputing a contest

**Admin → Contests → [contest] → Recompute** re-enqueues the full computation pipeline for a contest (Compute Flights through all downstream jobs). Use this when:

- A processing bug was fixed and results need to be regenerated
- A member merge changed which pilot is credited for results
- K-values or other configuration changed

## Merging duplicate members

Members are created automatically from JasPEr data using IAC numbers and names. Over time, the same person may end up with multiple records (different IAC numbers, name variations, etc.).

1. Go to **Admin → Members** and search for the person.
2. Select the records to merge and use **Merge Preview** to see what will happen.
3. Confirm with **Merge** to consolidate the records.

After merging, recompute any affected contests to update rankings.

## Merging duplicate aircraft records

Similar to member merges, aircraft make/model records can become duplicated.

1. Go to **Admin → Make Models** and find the duplicates.
2. Use **Merge Preview** then **Merge**.

## Managing K-factor limits

**Admin → Free Program Ks** manages the maximum allowed K-factor for each category per year. These limits are applied during JasPEr import to validate pilot sequences.

## Setting up live scoring

To enable live scoring display for an upcoming contest:

1. Go to **Admin → Contests → [contest] → Edit**.
2. Set `busy_start` to the first day of the contest and `busy_end` to the last day.
3. Save. The contest's live results page will now update as JasPEr exports are submitted.

## Managing collegiate teams

The HQ panel (`/hq/collegiate_teams/:year`) is used for managing collegiate team registrations. This requires HQ credentials (separate from `contest_admin`).
