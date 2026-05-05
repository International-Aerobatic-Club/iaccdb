# Judge Metrics

IACCDB computes quality metrics for every judge on every flight, and rolls those up to per-contest and per-year summaries. These metrics measure two qualities: **consistency** (how reliably the judge ranks pilots the same way as the panel) and **discrimination** (how well the judge distinguishes between pilots of different ability).

Metrics are displayed on each judge's profile page at `/judges/:id` and summarized at `/leaders/judges/:year`.

## Metric tables

| Scope | Table | Granularity |
|---|---|---|
| Per flight | `jf_results` | One judge on one flight |
| Per contest | `jc_results` | One judge across all flights in one category at one contest |
| Per year | `jy_results` | One judge across all contests in one year and category |

All three tables share the same column set. The per-contest and per-year records are produced by summing the intermediate statistical accumulators from the finer-grained records.

## Columns

### Consistency: sigma_ri_delta

`sigma_ri_delta` (and its sum `ri_total`) measure how far the judge's ranking of each pilot deviates from the panel consensus ranking.

- A lower `sigma_ri_delta` means the judge ranked pilots more consistently with the overall panel.
- This is the primary consistency metric displayed in the UI.

### Discrimination: con / dis / pair_count

`con` and `dis` are the counts of **concordant** and **discordant** pilot pairs.

- A concordant pair is one where the judge agreed with the panel on which pilot scored higher.
- A discordant pair is one where the judge disagreed.
- High `con` relative to `dis` indicates good discrimination.

From these, IACCDB computes Kendall's τ and Goodman-Kruskal γ — see [Judge Statistics](judge-statistics.md).

### Correlation intermediates

`ftsdx2`, `ftsdxdy`, `ftsdy2`, and `sigma_d2` are running sums of intermediate values used to compute Spearman's ρ and Pearson's correlation coefficient on demand without re-reading all the raw data.

### Outlier counts

| Column | Meaning |
|---|---|
| `minority_zero_ct` | Number of figures where this judge alone gave a zero when the rest of the panel did not |
| `minority_grade_ct` | Number of figures where this judge's grade was an outlier compared to the panel |

High outlier counts may indicate the judge was applying standards differently from the rest of the panel.

### Coverage statistics

| Column | Meaning |
|---|---|
| `pilot_count` | Total pilots judged |
| `figure_count` | Total figures judged |
| `flight_count` | Number of flights (1 for `jf_results`, multiple for `jc_results` and `jy_results`) |
| `total_k` | Sum of K-values for figures judged |
