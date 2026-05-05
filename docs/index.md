# IACCDB Documentation

The **IAC Contest Database (IACCDB)** is a Ruby on Rails web application that records and displays aerobatic contest results for the [International Aerobatic Club (IAC)](https://www.iac.org/). It is deployed publicly at [iaccdb.iac.org](https://iaccdb.iac.org/).

## What it does

- Stores raw judge grades from every IAC-sanctioned aerobatic contest
- Computes pilot standings per flight, per category, and per contest
- Computes judge quality metrics (consistency, discrimination, correlation) per flight, contest, and year
- Aggregates annual series standings: Regional, Soucy Cup, LEO/National Point Series, and Collegiate
- Provides public read access to all results and a protected endpoint for contest data submission

## Who uses it

| Role | What they do |
|---|---|
| **Pilots** | Look up their contest results, standings, and career history |
| **Judges** | Review their performance metrics across flights and contests |
| **Organizers** | Submit contest results via the JasPEr data format after each contest |
| **Admins** | Manage member records, recompute results, monitor the data pipeline |

## Where to start

- **New to the system?** Read [Domain Concepts](concepts/index.md) first.
- **Submitting contest data?** Go to [For Organizers](guides/organizers.md).
- **Understanding judge metrics?** See [Judge Metrics](scoring/judge-metrics.md) and [Judge Statistics](scoring/judge-statistics.md).
- **Setting up a dev environment?** Start with [Local Setup](development/setup.md).
- **Integrating with the API?** See [API Reference](api/index.md).
