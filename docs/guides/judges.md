# For Judges

This guide helps IAC judges understand and interpret their performance metrics on IACCDB.

## Finding your profile

Go to `https://iaccdb.iac.org/judges` and search for your name, or find yourself in the **Leaders → Judges** leaderboard.

Your profile page (`/judges/:id`) shows:

- All flights you have judged, with links to individual flight detail pages
- Quality metrics for each flight, contest, and year

## Understanding your metrics

IACCDB computes four statistics that measure the quality of your judging. All are derived by comparing how you ranked pilots against how the full judging panel ranked them.

### Rank deviation (σri)

The mean absolute difference between your ranking and the panel consensus ranking. **Lower is better.**

Example: if you ranked three pilots 1st, 3rd, and 2nd while the panel ranked them 1st, 2nd, and 3rd, the rank deviations are 0, 1, 1 — giving σri = 0.67.

### Kendall's τ and Goodman-Kruskal γ

Both measure **discrimination** — how well you distinguished between pilots. They count pairs of pilots and ask: for each pair, did you agree or disagree with the panel about which one scored higher?

- **Range:** −1 to +1
- **Higher is better**
- τ includes tied pairs in the denominator; γ excludes them (more useful when many scores are equal)

### Spearman's ρ

A correlation coefficient comparing your pilot rankings to the panel's. **Higher is better** (maximum +1 = perfect agreement).

See [Judge Statistics](../scoring/judge-statistics.md) for the full mathematical definitions.

### Outlier counts

- **Minority zeros:** times when you alone gave a hard zero while other judges did not
- **Minority grades:** times when your grade was significantly different from the rest of the panel

A high count of either can indicate differences in standards interpretation.

## Annual summary

The **Leaders → Judges** page (`/leaders/judges/:year`) shows all judges active in a given year, sorted by their consistency metrics. This is the best starting point for year-over-year comparison.

## Career summary

Your **CV page** (`/judge/:id/cv`) provides a career-long summary of your judging activity across all years and categories.

## Grade histograms

The histograms page (`/judge/:judge_id/flight/:flight_id`) shows the distribution of grades you gave in a specific flight, compared to the overall panel distribution. This can help identify if you are grading systematically high or low relative to the panel.
