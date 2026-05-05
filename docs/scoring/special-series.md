# Special Series Computation

After pilot contest results (`pc_results`) are computed, several annual series jobs aggregate them into standings.

## Regional Series

**Service:** `RegionalSeries` (`app/services/regional_series.rb`)

**Trigger:** Enqueued by Compute Contest Pilot Rollups Job for each contest.

**Logic:**

1. For each contest, find the contest's region.
2. Find all pilots with `pc_results` in that region for the current year.
3. For each (pilot, category) pair, aggregate their `pc_results` across all contests in the region into a `regional_pilots` record.
4. Compute `percentage` = total category value / total possible × 100.
5. Mark `qualified = true` if the pilot met the minimum contest participation threshold for their category.
6. Assign `rank` within region/category/year.

**Database:** `regional_pilots`, `region_contests`

---

## Soucy Cup

**Service:** `SoucyComputer` (`app/services/soucy_computer.rb`)

**Trigger:** Enqueued by Compute Contest Pilot Rollups Job; recomputes the entire year.

**Logic:**

1. Collect all `pc_results` for power pilots in the year.
2. Exclude glider and Four Minute categories.
3. For each pilot, separate national-championship results from regional results.
4. From the regional results, take the best two contest percentages.
5. Optionally integrate the national result as one of the two best, or as a bonus.
6. Store a `SoucyResult` per pilot per category per year.

**Database:** `results` (type = `SoucyResult`), `result_accums`

---

## LEO / National Point Series (NPSC)

**Service:** `LeoComputer` (`app/services/leo_computer.rb`) or similar

**Trigger:** Enqueued after Compute Contest Pilot Rollups Job.

**Logic:**

1. Collect all `pc_results` for power pilots across all contests in the year.
2. Primary category eligible from 2023 onward.
3. Aggregate points across contests per pilot per category.
4. Rank pilots nationally.

**Database:** `results` (type = `LeoRank`), `results` (type = `LeoPilotContest`)

---

## Collegiate Series

**Service:** `CollegiateComputer` (`app/services/collegiate_computer.rb`)

**Trigger:** Enqueued by Compute Contest Pilot Rollups Job; recomputes the entire year.

**Team results:**

1. Identify pilots marked `CollegiateSeries` (from JasPEr `SubCategory`).
2. Group by college/team.
3. Aggregate top team members' results.
4. Store a `CollegiateResult` per team per category per year.

**Individual results:**

1. Find collegiate pilots with results in at least three contests.
2. Average their top three contest percentages.
3. Store a `CollegiateIndividualResult` per pilot per category per year.

**Database:** `results` (type = `CollegiateResult` or `CollegiateIndividualResult`), `result_members`, `result_accums`
