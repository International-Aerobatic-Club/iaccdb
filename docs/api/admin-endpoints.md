# Admin Endpoints

Admin endpoints require HTTP Basic authentication with the `contest_admin` role from `config/admin.yml`.

## JasPEr submission (primary data import)

```
POST /admin/jasper
```

This is the most important admin endpoint. Contest organizers use it to submit contest results after each event.

**Request:**

| Parameter | Type | Description |
|---|---|---|
| `contest_xml` | string or file | JasPEr XML document |

Send as a multipart form upload (file) or as a plain string parameter.

**Response (HTTP 200 — accepted):**
```xml
<contest>
  <cdbId>42</cdbId>
</contest>
```
Processing is **asynchronous**. The `cdbId` is returned immediately; result computation happens in the background via delayed_job.

**Response (HTTP 400 — empty body):**
```xml
<exception>no contest data provided</exception>
```

**Response (HTTP 500 — XML parse error):**
```xml
<exception>error message here</exception>
```

**Curl example:**
```bash
curl -F "contest_xml=@my_contest.xml" \
     --user contest_admin:PASSWORD \
     https://iaccdb.iac.org/admin/jasper
```

See [JasPEr XML Format](../data-formats/jasper.md) for the full XML specification.

---

## Contests

| Method | Path | Description |
|---|---|---|
| GET | `/admin/contests` | List all contests |
| GET | `/admin/contests/:id` | Contest detail |
| PUT/PATCH | `/admin/contests/:id` | Update contest attributes |
| DELETE | `/admin/contests/:id` | Delete contest (JSON) |
| GET | `/admin/contests/:id/recompute` | Trigger full recomputation for contest |
| GET | `/admin/contests/:id/jc_results` | Judge metrics for contest |
| GET | `/admin/contests/:id/pc_results` | Pilot results for contest |

## Members

| Method | Path | Description |
|---|---|---|
| GET | `/admin/members` | Search members |
| GET | `/admin/members/:id` | Member detail |
| GET/PATCH | `/admin/members/:id/edit` | Edit member |
| POST | `/admin/members/merge_preview` | Preview member merge |
| POST | `/admin/members/merge` | Merge duplicate member records |

## Aircraft

| Method | Path | Description |
|---|---|---|
| GET | `/admin/make_models` | Aircraft index |
| GET/PATCH | `/admin/make_models/:id/edit` | Edit aircraft record |
| POST | `/admin/make_models/merge_preview` | Preview make/model merge |
| POST | `/admin/make_models/merge` | Merge duplicate aircraft records |

## Data posts

| Method | Path | Description |
|---|---|---|
| GET | `/admin/data_posts` | List all JasPEr submissions with status |
| GET | `/admin/data_posts/:id` | Submission detail and error info |
| GET | `/admin/data_post/:id/download` | Download the original XML for a submission |
| GET | `/admin/data_post/:id/resubmit` | Re-enqueue processing for a submission |

## Manny

| Method | Path | Description |
|---|---|---|
| GET | `/admin/manny_list` | List contests available in Manny system |
| GET | `/admin/manny_synchs` | List Manny sync records |
| DELETE | `/admin/manny_synchs/:id` | Delete a Manny sync record |
| GET | `/admin/manny_synchs/:manny_number/retrieve` | Trigger Manny retrieval |
| GET | `/admin/manny_synchs/:manny_number/show` | Show Manny data |

## Other

| Method | Path | Description |
|---|---|---|
| GET | `/admin/failures` | Error log for processing failures |
| GET | `/admin/failures/:id` | Failure detail |
| DELETE | `/admin/failures/:id` | Delete failure record |
| GET | `/admin/queues` | Background job queue status |
| GET/POST | `/admin/free_program_ks` | Manage max K-factors per category/year |
