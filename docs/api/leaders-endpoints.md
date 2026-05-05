# Leaders Endpoints

The `/leaders` namespace provides annual standings pages. All return HTML. Year is optional; omitting it defaults to the current or most recent year.

| Method | Path | Description |
|---|---|---|
| GET | `/leaders/chiefs/:year` | Chief judges active in year |
| GET | `/leaders/chiefs` | Chief judges (recent year) |
| GET | `/leaders/judges/:year` | Judge quality leaderboard for year |
| GET | `/leaders/judges` | Judge quality leaderboard (recent year) |
| GET | `/leaders/regionals/:year` | Regional series standings for year |
| GET | `/leaders/regionals` | Regional series standings (recent year) |
| GET | `/leaders/soucy/:year` | Soucy Cup standings for year |
| GET | `/leaders/soucy` | Soucy Cup standings (recent year) |
| GET | `/leaders/leo/:year` | LEO / National Point Series standings for year |
| GET | `/leaders/leo` | LEO standings (recent year) |
| GET | `/leaders/collegiate/:year` | Collegiate series standings for year |
| GET | `/leaders/collegiate` | Collegiate standings (recent year) |
| GET | `/leaders/pilot_contest_counts/:year` | Contest participation counts for year |
| GET | `/leaders/pilot_contest_counts` | Contest participation counts (recent year) |
