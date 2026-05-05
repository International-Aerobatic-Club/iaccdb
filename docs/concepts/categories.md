# Categories

Aerobatic pilots compete in one of six **Categories** based on skill level. Categories are further divided by aircraft type: **Power** (P) and **Glider** (G).

## Category levels

| JasPEr ID | Name | Description |
|---|---|---|
| 1 | Primary | Entry-level; simple maneuvers, judged on a defined known sequence only |
| 2 | Sportsman | Beginner/intermediate; known and free sequences |
| 3 | Intermediate | Known, free, and unknown sequences |
| 4 | Advanced | Known, free, and unknown sequences; more difficult figures |
| 5 | Unlimited | Highest level; known, free, and two unknown sequences |
| 6 | Four Minute | Freestyle category; pilot designs a four-minute free program |

The **JasPEr ID** (1–6) is the `CategoryID` attribute used in JasPEr XML files. See [JasPEr XML](../data-formats/jasper.md).

## Aircraft types (aircat)

| Code | Meaning |
|---|---|
| P | Powered aircraft |
| G | Glider / motorglider |
| F | Four Minute (internally treated as its own aircat) |

The `aircat` determines which series standings a result contributes to. Soucy Cup and LEO/NPSC standings are power-only.

## Flights within a category

Most categories include multiple flights (scored sessions). The flight types are:

| JasPEr ID | Flight name | Who flies it |
|---|---|---|
| 1 | Known | All categories except Four Minute |
| 2 | Free | Sportsman and above |
| 3 | Unknown | Intermediate and above |
| 4 | Unknown II | Unlimited only |

Primary pilots fly only the Known sequence.

## Synthetic categories

IACCDB can create **synthetic categories** that aggregate flights from a regular category in a customized way (for example, combining a subset of flights for a special award). Synthetic categories are marked with `synthetic: true` in the database and are not submitted via JasPEr — they are created by administrators.
