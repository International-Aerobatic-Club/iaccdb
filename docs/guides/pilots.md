# For Pilots

This guide explains how to find and interpret your contest results on IACCDB.

## Finding your results

Go to `https://iaccdb.iac.org/pilots` and search for your name. Your profile page (`/pilots/:id`) shows:

- All contests you have competed in
- Your result in each category at each contest
- Links to individual flight details

## Reading your contest results

On a contest page (`/contests/:id`), results are grouped by category. For each category you'll see:

| Column | Meaning |
|---|---|
| Rank | Your standing among competitive pilots in this category |
| Category value | Your total points across all flights in the category |
| % possible | Your score as a percentage of the maximum possible |

**Hors Concours (HC)** pilots appear in the listing but are not assigned a competitive rank. See [Hors Concours](../concepts/hors-concours.md).

## Reading your flight detail

Each flight link shows your individual figure scores from each judge, plus the averaged result. The figure scores show:

- Your grade for each figure (from each judge)
- The K-value for each figure
- The resulting points (grade × K)
- Your rank on each figure compared to other pilots

## Annual series

### Regional standings

Find your regional series results at **Leaders → Regionals** (`/leaders/regionals/:year`). You appear in the region where your contests were held. Qualification typically requires a minimum number of contests in the region during the year.

### Soucy Cup

The **Leaders → Soucy** page (`/leaders/soucy/:year`) shows standings for the Soucy Award — awarded to the top power pilot in each category based on their best two results across eligible contests.

### LEO / National Point Series

**Leaders → LEO** (`/leaders/leo/:year`) shows national standings for power pilots.

### Collegiate

If you flew under the `CollegiateSeries` subcategory, your individual results appear at **Leaders → Collegiate**. Qualification for individual ranking requires results in at least three contests; your standing is based on the average of your top three contest percentages.

## Star qualifying

A **star** icon on your contest result indicates your score qualified for a star award in that category. The qualifying threshold is set by IAC rules.
