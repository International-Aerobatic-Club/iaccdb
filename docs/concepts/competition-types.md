# Competition Types

IACCDB tracks several annual series that aggregate results across multiple contests.

## Regional Series

The IAC is divided into geographic regions (e.g., NorthEast, SouthEast, NorthWest, etc.). Pilots competing in a region accumulate results across all contests held in that region during the year.

- A pilot must meet a minimum participation threshold to be **qualified** in a regional series.
- The regional ranking is based on percentage of total possible points.
- Stored in the `regional_pilots` and `region_contests` tables.

## Soucy Cup

The Soucy Award is the IAC's annual championship for power pilots. It is awarded to the top pilot in each category based on their **best two results from four eligible contests** during the year.

- Eligible contests: regional contests (non-nationals) plus the national championship
- National result is treated separately and integrated as a potential best result
- Power categories only (aircat = P)
- Stored as `SoucyResult` records in the `results` table

## LEO / National Point Series (NPSC)

The **Leading Edge Operator (LEO)** award, also called the National Point Series, ranks pilots nationally across all IAC contests during the year.

- Power categories only
- Primary category eligible since 2023
- Stored as `LeoRank` and `LeoPilotContest` records in the `results` table

## Collegiate

The **Collegiate Series** tracks pilots who are currently enrolled college or university students.

- **Team results** aggregate the top performers from a registered collegiate team
- **Individual results** rank collegiate pilots who competed in at least three contests; the ranking uses the average of their top three contest percentages
- Stored as `CollegiateResult` (team) and `CollegiateIndividualResult` (individual) records

## National Championship

The IAC holds a national championship each year. This is a regular contest in the database (with `region` set to `"National"` or similar), but its results feed into the Soucy and LEO calculations with special handling.
