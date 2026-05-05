# API Reference

IACCDB is a Rails web application. Most pages return HTML, but several endpoints accept or return JSON. The admin JasPEr submission endpoint accepts XML.

## Authentication

**Public endpoints** require no authentication.

**Admin endpoints** use HTTP Basic authentication. Credentials are configured in `config/admin.yml` (copied from `config/admin.yml.sample` during setup). The relevant role is `contest_admin`.

**HQ endpoints** (collegiate team management) use a separate HQ credential configured in the same file.

## Content types

| Namespace | Default response format |
|---|---|
| Public routes | HTML |
| `/leaders/*` | HTML (some actions support JSON) |
| `POST /admin/jasper` | XML |
| `DELETE /admin/contests/:id` | JSON |
| `/hq/collegiate*` | JSON |

## Base URL

Production: `https://iaccdb.iac.org`

Development: `http://localhost:3000`

## Sections

- [Public Endpoints](public-endpoints.md) — contests, pilots, judges, flights, results
- [Leaders Endpoints](leaders-endpoints.md) — annual standings pages
- [Admin Endpoints](admin-endpoints.md) — data submission and management
- [Live Results](live-results.md) — real-time contest scoring endpoints
