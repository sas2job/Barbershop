# Barbershop project instructions

## Project purpose

- Build a responsive Ruby on Rails barbershop booking application.
- Use the project to learn and document AI-assisted software development concepts.
- Treat `docs/product-brief.md` as the current source of product requirements.
- Treat undecided items as open questions, not implicit requirements.

## Working process

- Inspect relevant code and documentation before proposing changes.
- Separate user requirements, assumptions, and technical decisions.
- For non-trivial work, state acceptance criteria and make a small verifiable change.
- Verify behavior with the narrowest relevant test, then run the broader applicable suite.
- Update specifications, ADRs, and learning notes when behavior or an architectural decision changes.
- When the user has explicitly requested an implementation task, proceed with safe in-scope changes immediately; do not ask for confirmation at each routine step.
- When the user explicitly authorizes a specific in-scope action, treat that authorization as sufficient and perform it without asking again, including staging related files and creating a Git commit when requested.
- For routine confirmations within an explicitly authorized task, answer affirmatively and continue execution immediately, while still reporting blockers accurately and preserving safety constraints.
- Do not report completion without evidence from tests, checks, or a reproducible manual verification.

## Product rules

- A client books a service and time, not a specific barber.
- An administrator may assign or replace the barber.
- A booking is confirmed immediately after successful slot reservation.
- Clients do not have accounts; they provide a name and phone number.
- Client access uses a unique, unpredictable public token.
- Rescheduling creates a new booking and annuls the previous one atomically.
- If the new slot cannot be reserved, the previous booking remains active.
- Cancelled and annulled bookings remain in the database for history but do not occupy a slot.

## Safety

- Never expose names, phone numbers, tokens, credentials, or production data in logs or examples.
- Never use a sequential database ID as authorization for a public booking page.
- Do not add production dependencies without explaining their purpose and tradeoffs.
- Do not run destructive database, Git, filesystem, or deployment operations without explicit approval.
- Prefer database constraints and transactions for concurrency invariants.

## Current verification

- Install dependencies with `bundle install`.
- Verify framework boot with `bin/rails runner 'puts Rails.version'`.
- Prepare PostgreSQL databases with `bin/rails db:prepare`.
- Run tests with `bin/rails test`.
- Run style checks with `bin/rubocop`.
- Run the local security scan with `bundle exec brakeman --no-pager`.
- The generated `bin/brakeman` additionally enforces an online latest-version check and can fail before scanning when that service is unavailable.
- Database preparation requires access to the local PostgreSQL socket.
