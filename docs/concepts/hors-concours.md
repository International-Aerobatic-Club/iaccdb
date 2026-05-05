# Hors Concours (HC)

A pilot flying **hors concours** (HC) participates in a flight and receives scores, but their results do not count for competition ranking. Their scores still appear in the public record and still affect judge metric calculations.

## When HC applies

Pilots fly HC for various reasons:

| Reason | Description |
|---|---|
| No reason given | General HC flag with no specific cause recorded |
| No competition | No competitive pilots in the category at this contest |
| Flying a higher category | Pilot is officially entered in a higher category but flew a lower one |
| Not qualified | Pilot does not meet the requirements for ranked competition |

## How HC is recorded in JasPEr

There are two ways to mark a pilot as hors concours in a JasPEr XML file:

1. **Append `(patch)` to the pilot's last name** — the parser strips this suffix and sets the HC flag. This is case-insensitive: `(Patch)`, `(PATCH)`, etc. are all recognized.
2. **Set the `SubCategory` element to `HorsConcours`** — the parser checks for this string.

Example:
```xml
<Pilot PilotID="3">
  <IACNumber>12345</IACNumber>
  <Name>
    <First>Jane</First>
    <Last>Smith (patch)</Last>
  </Name>
</Pilot>
```

Or using SubCategory:
```xml
<Pilot PilotID="3">
  <IACNumber>12345</IACNumber>
  <Name><First>Jane</First><Last>Smith</Last></Name>
  <SubCategory>HorsConcours</SubCategory>
</Pilot>
```

## HC in the database

The HC flag is stored as an integer bitfield in two columns:

- `pilot_flights.hors_concours` — set during import from JasPEr
- `pc_results.hors_concours` — propagated during contest result computation

HC pilots appear in flight listings but are excluded from ranked standings.
