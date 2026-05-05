# Public Endpoints

All routes below return HTML unless otherwise noted. No authentication required.

## Contests

| Method | Path | Description |
|---|---|---|
| GET | `/contests` | List all contests |
| GET | `/contests/:id` | Contest detail with flights, categories, and pilot results |

## Pilots

| Method | Path | Description |
|---|---|---|
| GET | `/pilots` | Pilot search/index |
| GET | `/pilots/:id` | Pilot profile: contest history, category results |
| GET | `/pilots/:id/scores/:id` | Pilot score detail for one contest |

## Judges

| Method | Path | Description |
|---|---|---|
| GET | `/judges` | Judge search/index |
| GET | `/judges/:id` | Judge profile: flight history and quality metrics |
| GET | `/judge/:id/cv` | Judge career summary |
| GET | `/judge/activity` | Recent judge activity (current year) |
| GET | `/judge/activity/:year` | Judge activity for a specific year |
| GET | `/judge/:judge_id/flight/:flight_id` | Histograms of judge grades for one flight |

## Chiefs

| Method | Path | Description |
|---|---|---|
| GET | `/chiefs` | Chief judge index |
| GET | `/chiefs/:id` | Chief judge profile |
| GET | `/chief/:id/cv` | Chief judge career summary |

## Assistants

| Method | Path | Description |
|---|---|---|
| GET | `/assistants` | Assistant index |
| GET | `/assistants/:id` | Assistant profile |

## Flights and Results

| Method | Path | Description |
|---|---|---|
| GET | `/flights/:id` | Flight detail: pilots, judges, scores |
| GET | `/pilot_flights/:id` | One pilot's performance in one flight |
| GET | `/jf_results/:id` | Judge quality metrics for one flight |

## Aircraft

| Method | Path | Description |
|---|---|---|
| GET | `/make_models` | Aircraft database index |
| GET | `/make_models/:id` | Aircraft model detail |

## Further / Analytics

| Method | Path | Description |
|---|---|---|
| GET | `/further/participation` | Contest participation statistics |
| GET | `/further/airplanes` | Aircraft statistics (current year) |
| GET | `/further/airplanes/:year` | Aircraft statistics for a specific year |

## Pages

| Method | Path | Description |
|---|---|---|
| GET | `/pages/:title` | Static content pages |
