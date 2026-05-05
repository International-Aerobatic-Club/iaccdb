# Contributing

## Workflow

This project follows [GitHub Flow](https://guides.github.com/introduction/flow/):

1. Fork the repository
2. Create a branch from `master`
3. Make your changes
4. Open a pull request — any PR will receive a response
5. Bug fixes with tests are especially welcome

If your contribution might require significant time and effort, get in touch first with your proposal.

## Tests

The project has two test suites:

```bash
rspec spec       # RSpec (older tests)
rails test       # Minitest (newer tests)
```

Include tests with bug fixes. Failing tests block merges.

## Code conventions

- Ruby 2.7 syntax
- Rails 5.2 conventions
- Follow existing patterns for models, services, and controllers
- Service objects go in `app/services/`
- Background jobs go in `app/services/jobs/`

## Issues

[Bug reports and feature requests](https://github.com/wbreeze/iaccdb/issues) are tracked on GitHub.
