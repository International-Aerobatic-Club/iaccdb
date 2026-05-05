# Data Formats

Contest data enters IACCDB through two import paths.

## JasPEr XML (primary)

**JasPEr** (Judged Aerobatic Scoring Program) is the scoring software used by IAC contest organizers to record results during a contest. After a contest concludes, JasPEr exports the results as an XML document that is POSTed to IACCDB's admin endpoint.

This is the primary and preferred method for submitting contest data. See [JasPEr XML](jasper.md) for the full format specification.

## Manny (legacy)

**Manny** is a legacy synchronization system. IACCDB can retrieve contest data from the Manny system via the `MannySynch` admin interface. This path is less commonly used and exists primarily for historical data retrieval.

See [Manny](manny.md) for details.

## Processing pipeline

Regardless of which format is used, data enters the same background processing pipeline once imported. See [Scoring Engine: Pipeline Overview](../scoring/index.md).
