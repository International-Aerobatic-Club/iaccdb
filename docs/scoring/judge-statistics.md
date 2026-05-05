# Judge Statistics

IACCDB uses four statistical measures to quantify judge performance. This page defines each measure and explains what it means for contest judging.

The formulas below use:

- \(n\) — number of pilots ranked
- \(x_p\) — this judge's rank for pilot \(p\)
- \(y_p\) — the consensus panel rank for pilot \(p\)
- \(N_c\) — number of concordant pilot pairs
- \(N_d\) — number of discordant pilot pairs

---

## Spearman's ρ (rank correlation)

\[
\rho = 1 - \frac{6 \sum d_p^2}{n(n^2 - 1)}
\]

where \(d_p = x_p - y_p\) is the difference between the judge's rank and the consensus rank for pilot \(p\).

**Interpretation:** ρ ranges from −1 to +1. A value near +1 means the judge ranked pilots in almost the same order as the panel. A value near 0 means no agreement. A value near −1 means the judge ranked pilots in the opposite order.

When ranks are tied among \(m\) pilots sharing rank \(r\), the tied values are replaced by their average: \(r + (m-1)/2\). For example, three pilots tied for third each receive rank \(4\).

The Pearson form (equivalent for rank data with tie correction) is:

\[
\rho = \frac{\sum_p (x_p - \bar{x})(y_p - \bar{y})}{\sqrt{\sum_p (x_p - \bar{x})^2 \cdot \sum_p (y_p - \bar{y})^2}}
\]

where \(\bar{x} = \bar{y} = (n+1)/2\) is the mean rank.

---

## Kendall's τ

\[
\tau = \frac{N_c - N_d}{\frac{1}{2} n (n-1)}
\]

**Interpretation:** τ ranges from −1 to +1. The denominator \(\frac{1}{2}n(n-1)\) is the total number of pilot pairs. A value near +1 means the judge agreed with the panel on the relative ordering of nearly every pair of pilots.

---

## Goodman-Kruskal γ

\[
\gamma = \frac{N_c - N_d}{N_c + N_d}
\]

**Interpretation:** Unlike τ, γ ignores tied pairs entirely (pairs where one or both rankings are tied are excluded from both numerator and denominator). This makes γ more stable when many pilots have equal scores. γ also ranges from −1 to +1.

---

## Rank deviation (ri / sigma_ri_delta)

\[
\sigma_{ri} = \frac{\sum_p |x_p - y_p|}{n}
\]

Stored as `sigma_ri_delta` (the mean) and `ri_total` (the sum before dividing).

**Interpretation:** This is the mean absolute rank deviation — the average number of positions by which the judge's rankings differed from the consensus. Lower is better; zero means perfect agreement.

---

## Stored accumulators

Because metrics need to be rolled up across multiple flights without re-reading raw data, IACCDB stores intermediate summation terms:

| Column | Formula |
|---|---|
| `sigma_d2` | \(\sum d_p^2\) — for Spearman's ρ |
| `ftsdx2` | \(\sum (x_p - \bar{x})^2\) — for Pearson |
| `ftsdxdy` | \(\sum (x_p - \bar{x})(y_p - \bar{y})\) — for Pearson |
| `ftsdy2` | \(\sum (y_p - \bar{y})^2\) — for Pearson |
| `con` | \(N_c\) — for Kendall τ and γ |
| `dis` | \(N_d\) — for Kendall τ and γ |
| `ri_total` | \(\sum |x_p - y_p|\) — for mean rank deviation |

When aggregating across multiple flights (`jc_results`, `jy_results`), these accumulators are simply summed. The final metric values are computed from the summed accumulators at display time.
