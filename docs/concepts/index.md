# Domain Concepts

IACCDB tracks IAC aerobatic competition data. This page explains the core concepts you need to understand the rest of the documentation.

## The IAC

The [International Aerobatic Club](https://www.iac.org/) is the governing body for aerobatic competition in the United States. The IAC sanctions contests held throughout the year at regional and national levels.

## Members

Everyone in the system — pilots, judges, chief judges, and assistants — is a **Member** identified by their **IAC membership number (IAC ID)**.

## Contests

A **Contest** is a single aerobatic competition event. It has a name, location (city/state), date, hosting chapter, director, and region. A contest can span multiple days and include multiple **Flights** in multiple **Categories**.

## Categories

Pilots compete in one of six **Categories** based on skill level. See [Categories](categories.md) for the full breakdown.

## Flights

A **Flight** is one scored session within a contest and category — for example, the Known sequence flown by Advanced Power pilots. Each flight has a chief judge (and optional assistant) and a set of line judges.

## Pilots and PilotFlights

A **PilotFlight** records one pilot's participation in one flight. It includes their routine (the sequence of figures they flew), their aircraft, their chapter affiliation, any penalty points, and whether they flew hors concours.

## Judges and Scores

Each line judge scores every pilot in a flight. A **Score** stores the individual grades for one judge on one pilot. Grades are decimal numbers; see [JasPEr XML](../data-formats/jasper.md#grade-encoding) for special grade values (averages, zeroes).

## Results

Raw scores flow through a multi-stage computation pipeline to produce ranked results at the flight, contest, and annual series level. See [Scoring Overview](scoring-overview.md) and the [Scoring Engine](../scoring/index.md) section for details.

## Data Import

Contest data enters IACCDB through two paths:

- **JasPEr XML** — the primary method; contest organizers POST XML exported from the JasPEr scoring program
- **Manny** — a legacy synchronization system

See [Data Formats](../data-formats/index.md).
