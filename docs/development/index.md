# Development Overview

IACCDB is a Ruby on Rails 5.2 application backed by MySQL. It uses:

- **Ruby 2.7.8** (pinned in `.ruby-version`)
- **Rails 5.2**
- **MySQL** (databases: `cdb_dev` for development, `cdb_test` for tests)
- **delayed_job** for background job processing
- **Foundation** for CSS/UI
- **RSpec** and **Minitest** for tests

## Quick links

- [Local Setup](setup.md) — getting the app running on your machine
- [Architecture](architecture.md) — codebase structure and key services
- [Contributing](contributing.md) — how to submit changes

## Deployed instance

The production app is at [https://iaccdb.iac.org/](https://iaccdb.iac.org/).
