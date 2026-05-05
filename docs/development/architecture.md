# Architecture

## Directory structure

```
app/
  controllers/           Rails controllers
    admin/               Admin-only controllers
    hq/                  HQ collegiate management
    leaders/             Annual standings
    further/             Analytics
  models/                ActiveRecord models
  services/
    jasper/              JasPEr XML parsing and import
    manny/               Manny format parsing and import
    jobs/                Background job classes
    flight_computer.rb   Core scoring computation
    category_rollups.rb  Contest-level aggregation
    judge_rollups.rb     Year-level judge aggregation
    contest_computer.rb  Orchestrates all computations
    find_stars.rb        Star-qualifying detection
    regional_series.rb   Regional standings
    soucy_computer.rb    Soucy Cup standings
    collegiate_computer.rb  Collegiate standings
    leo_computer.rb      LEO / NPSC standings
  views/                 ERB templates
config/
  routes.rb              All URL routes
  admin.yml              Authentication credentials (not in git)
  database.yml           Database connection (not in git)
db/
  schema.rb              Authoritative database schema
  migrate/               Migration history
cmd/                     One-off command scripts (Rails runner)
doc/                     Source files for diagrams
  computations.plantuml  Computational dependency diagram source
  jobs.plantuml          Job sequence diagram source
  metrics.tex            Judge statistics formulas (LaTeX)
spec/                    RSpec tests
test/                    Minitest tests
```

## Background jobs

Background processing uses the **delayed_job** gem. Jobs are defined in `app/services/jobs/` and enqueued via `Delayed::Job.enqueue`.

The job chain for a contest import:

```
ProcessJasperJob
  → ComputeFlightsJob
      → ComputeJudgeFlightMetricsJob
          → ComputeContestJudgeRollupsJob
              → ComputeYearRollupsJob
      → ComputeContestPilotRollupsJob
          → FindStarsJob
          → ComputeRegionalJob
          → ComputeSoucyJob
          → ComputeCollegiateJob
```

## Updating PlantUML diagrams

The source diagrams are in `doc/computations.plantuml` and `doc/jobs.plantuml`. The pre-rendered PNGs in `docs/assets/images/` are what gets displayed in this documentation.

To regenerate after editing a `.plantuml` file:

```bash
plantuml doc/computations.plantuml
cp doc/computations.png docs/assets/images/computations.png

plantuml doc/jobs.plantuml
cp doc/jobs.png docs/assets/images/jobs.png
```

Requires [PlantUML](https://plantuml.com/) (Java-based) to be installed.

## Authentication

Admin authentication is HTTP Basic. Credentials are read from `config/admin.yml` (not in git; copy from `config/admin.yml.sample`). The `contest_admin` role is used for JasPEr submission and the admin panel. A separate HQ credential is used for the collegiate management HQ panel.

## Data integrity patterns

- **Member merging:** Administrators can merge duplicate `members` records. The merge reassigns all associated records to the surviving member.
- **DataPost history:** Every JasPEr submission is stored in `data_posts` with the original XML. Submissions can be downloaded and resubmitted from the admin panel.
- **Failure tracking:** Processing errors are stored in `failures` with step name and description, linked to the contest and data post.
- **Need_compute flags:** `pf_results`, `pfj_results`, and `pc_results` have a `need_compute` column. When `true`, the record is stale and needs recomputation.
