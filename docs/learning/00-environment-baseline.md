# Environment baseline

Recorded on 2026-08-19 before generating the Rails application.

| Component | Installed version |
|---|---|
| Ruby | 4.0.2 |
| Ruby on Rails | 8.1.3 |
| Bundler | 4.0.10 |
| PostgreSQL client | 18.4 |
| Node.js | 20.18.0 |
| npm | 10.8.2 |
| Docker | 29.1.3 |

The generated `Gemfile.lock` resolves Rails to 8.1.3.1.

## Repository state

- The workspace initially contained planning documents but no application code.
- Git was initialized after the context-engineering exercise.
- The primary branch is `main`.
- A Rails 8.1 application was generated with PostgreSQL and the default Rails-native stack.

## Initial verification

| Check | Result |
|---|---|
| Rails boot | Passed; reported Rails 8.1.3.1 |
| Dependency resolution | Passed |
| RuboCop | Passed; 23 files, no offenses |
| Brakeman scanner | Passed; no warnings |
| Test command | Passed, but contains 0 tests and therefore proves little behavior |
| PostgreSQL preparation | Not verified because access to the local system socket was not approved |

The first `bin/brakeman` attempt failed inside its forced online latest-version check before scanning the application. Running the scanner directly with `bundle exec brakeman --no-pager` separated the tool-update check from the code scan and completed successfully.

## Why record a baseline

A reproducible environment is part of the agent's context. Exact versions make failures easier to reproduce and prevent an agent from silently assuming a different runtime or framework behavior.
