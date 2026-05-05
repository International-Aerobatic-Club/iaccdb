# Judge Teams

## Important: the `judges` table is not a list of judges

The `judges` table does **not** store the people who judge. The people are in the `members` table. The `judges` table stores **judge team pairs** — a line judge member paired with an optional assistant member.

This naming is counterintuitive and trips up anyone reading the schema for the first time.

## Structure

Table: `judges`

| Column | Type | Description |
|---|---|---|
| `judge_id` | bigint | FK to `members` — the person acting as line judge |
| `assist_id` | bigint | FK to `members` — the judge's assistant (optional, nullable) |

Each row in `judges` represents a unique (judge, assistant) pair. If a judge works alone at one contest and with an assistant at another, they will appear as two separate `judges` records.

## Relationships

```
judges.judge_id  → members.id   (the judge person)
judges.assist_id → members.id   (the assistant person, optional)

scores.judge_id  → judges.id    (raw grades from this team)
pfj_results.judge_id → judges.id
jf_results.judge_id  → judges.id
jc_results.judge_id  → judges.id
jy_results.judge_id  → judges.id
```

## Chief judges

The **chief judge** is different from line judges. Chiefs are stored directly on the `flights` table:

```
flights.chief_id  → members.id   (the chief judge person)
flights.assist_id → members.id   (the chief's assistant, optional)
```

Chiefs are presented separately in IACCDB at `/chiefs/:id`.

## Finding a judge's history

To find all contests where a member judged as a line judge:

1. Look up the `judges` records where `judge_id = member.id`
2. Follow those to `scores` or `jf_results` to find the flights/contests
