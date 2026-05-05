# Contest Rollups

After flight results are computed, `CategoryRollups` (`app/services/category_rollups.rb`) aggregates them into per-contest results.

## compute_pilot_category_results

Produces `pc_results` for each pilot in each category of the contest.

For each (category, pilot) pair:

1. Collect all `pf_results` for this pilot's flights in this category
2. Sum `adj_flight_value` across all flights to produce `pc_results.category_value`
3. Sum `total_possible` across all flights to produce `pc_results.total_possible`
4. Propagate the `hors_concours` flag from `pilot_flights`

## compute_category_ranks

Assigns `pc_results.category_rank` within each category.

- Only competitive pilots (HC = 0) receive a rank
- Ties are possible; tied pilots share the same rank

## compute_judge_category_results

Produces `jc_results` for each judge in each category.

For each (category, judge) pair:

1. Collect all `jf_results` for this judge's flights in this category
2. Sum the statistical accumulators (`ftsdx2`, `ftsdxdy`, `ftsdy2`, `sigma_d2`, `con`, `dis`, etc.)
3. Sum `pilot_count`, `figure_count`, `flight_count`

The final correlation metrics (Spearman ρ, Pearson, Kendall τ, Goodman-Kruskal γ) are computed on demand from the stored accumulators when displaying results.

## Find Stars

After pilot rollups are computed, `FindStars` (`app/services/find_stars.rb`) marks `pc_results.star_qualifying = true` for pilots who achieved a score threshold qualifying them for a star award in their category.
