# Study Flow: Application Structure and Review

Review date: 2026-11-02

This document describes the Rails application as it exists in this repository and records the highest-priority behavior gaps found in a source review. It is a code and test-coverage review, not a production-readiness certification.

## Application overview

Study Flow is a server-rendered Rails application for managing study plans and tracking study sessions. It uses Rails 8.1, Ruby 3.4, PostgreSQL, Hotwire/Turbo, Action Text, Active Storage, and Minitest. Background work uses Active Job with Solid Queue in production; Solid Cache and Solid Cable are also configured as database-backed production services.

The main user journey is:

1. Register or sign in.
2. Create study plans and add topics.
3. Start, edit, view, and complete study sessions.
4. Review dashboard activity and notifications.
5. Update profile and study preferences.
6. Receive scheduled reminders and weekly progress reports.

## Source structure

| Area | Responsibility |
|---|---|
| [`app/controllers/`](./app/controllers/) | HTTP endpoints, authentication entry points, parameter filtering, and response selection. |
| [`app/models/`](./app/models/) | Active Record domain models, validation, associations, scopes, and Turbo broadcast callbacks. |
| [`app/views/`](./app/views/) | HTML, email, and Turbo Stream templates. |
| [`app/jobs/`](./app/jobs/) | Daily reminder scheduling, notification delivery, and weekly report processing. |
| [`app/mailers/`](./app/mailers/) | Password reset, notification, and report emails. |
| [`app/services/report_generator.rb`](./app/services/report_generator.rb) | Creates CSV reports and attaches them to report records. |
| [`app/channels/`](./app/channels/) | Action Cable connection setup and current-user identification. |
| [`app/javascript/`](./app/javascript/) | Importmap-based JavaScript and Stimulus setup. |
| [`config/routes.rb`](./config/routes.rb) | Resource routes for plans, topics, sessions, notifications, settings, and authentication. |
| [`config/`](./config/) | Environment, database, storage, queue, cache, cable, and recurring-job configuration. |
| [`db/`](./db/) | PostgreSQL schema, migrations, seeds, and Solid Queue/Cache/Cable schemas. |
| [`test/`](./test/) | Minitest model, controller/request, mailer, job, integration, and system tests with YAML fixtures. |

The README documents setup, required services, scheduled jobs, production configuration, and test commands, including browser-test requirements.

## Domain model

- **User** owns sessions, study plans, notifications, and reports. The user also has an avatar and JSON study preferences.
- **StudyPlan** belongs to a user and owns topics.
- **Topic** belongs to a study plan, has attached resources, and owns study sessions.
- **StudySession** belongs to a topic, stores rich-text notes, and is considered active while `finished_at` is unset.
- **Notification** belongs to a user and tracks read state. `Notification::DailyReminder` creates daily reminder records.
- **Report** belongs to a user and has an attached file. `Reports::WeeklyProgress` calculates weekly session totals.
- **Session** is the cookie-backed authentication session. `Current` exposes the current session and its user for the request.

The primary schema is in [`db/schema.rb`](./db/schema.rb). Active Storage and Action Text tables are included there; Solid Queue, Cache, and Cable use separate schemas.

## Request and background flows

### Authentication

The [`Authentication` concern](./app/controllers/concerns/authentication.rb) protects controllers by default. Registrations, sign-in, and password endpoints opt out as needed. Successful sign-in creates a database session and stores its signed ID in a permanent, HTTP-only cookie. Sign-out destroys the current session.

### Study plans, topics, and sessions

The dashboard loads the current user’s plans and their active and recently completed sessions. Study-plan, topic, and study-session reads and writes are scoped through the current user’s associations. Parent records for new topics and sessions are resolved through those scoped associations.

Study sessions broadcast changes through Turbo Streams. A model validation prevents a second active session for the same topic during ordinary sequential requests.

### Notifications and preferences

Notifications can be listed, shown, marked read/unread, or bulk-marked read. The unread count is broadcast after notification creation and updates. Profile and preference settings are updated through separate controllers.

### Reminders and reports

[`config/recurring.yml`](./config/recurring.yml) defines a per-minute daily-reminder dispatcher and hourly report-scheduler entries for development and production. The dispatcher queues reminder jobs for eligible users with study plans once their configured local time arrives. It accounts for each user's timezone, catches up after a skipped spring-forward time, and avoids another reminder on the same local date during a repeated fall-back hour. The report scheduler checks each eligible user’s configured day/time and queues the weekly report job. The report job generates a CSV, attaches it to a report, and emails it.

### Storage and infrastructure

Development and test use PostgreSQL configuration in [`config/database.yml`](./config/database.yml). Production config separates the primary, cache, queue, and cable databases. Local file storage is configured for development/production; tests use temporary disk storage. Production queue processing is configured to run within Puma by default in [`config/deploy.yml`](./config/deploy.yml).

## Existing test coverage

The test suite includes:

- Model tests for associations, validations, scopes, preferences, and the active-session rule.
- Controller/request tests for common success, validation, authentication, and ownership cases.
- Mailer tests for recipients, subjects, content, and report attachments.
- Job tests for reminders, notifications, report generation, and scheduler timing.
- An integration test covering sign-in through completing a study session.
- A Selenium/Capybara system test covering sign-up through completing a study session.

The test suite covers the behaviors listed below. The system-test base uses headless Chrome, so executing browser tests requires Chrome and a compatible Selenium setup. GitHub Actions runs the Rails suite and system tests against PostgreSQL; [`config/ci.rb`](./config/ci.rb) includes those same test commands.

## Prioritized work

Priority meanings: **P1** = high impact; address before relying on the affected feature or broadening access. **P2** = important functional reliability or user-facing completeness. **P3** = hardening and scale follow-up.

### P1 — High priority

1. **Enforce ownership for topics and study sessions — implemented**
   - Both controllers find records through the current user's associations and resolve parent records through scoped associations.
   - Controller tests cover cross-user show/edit/update/delete/complete requests and attempts to create records under another user's parent.

2. **Complete password-reset token support — implemented**
   - [`User`](./app/models/user.rb) generates signed password-reset tokens with a 15-minute expiration and invalidates them when the password changes.
   - The controller returns a deliberate redirect for invalid or expired links and destroys existing sessions after a successful reset.
   - Controller and mailer tests exercise real tokens, expiry, password mismatch, and session invalidation.

3. **Verify recurring reminders and reports in production — configuration verified**
   - [`config/recurring.yml`](./config/recurring.yml) includes both jobs in production, and [`config/deploy.yml`](./config/deploy.yml) enables the Solid Queue supervisor in Puma.
   - Regression tests check the production schedules and supervisor setting. Actual queue processing still requires verification in a production-like deployment.

4. **Prevent duplicate weekly reports — implemented**
   - [`ReportSchedulerJob`](./app/jobs/report_scheduler_job.rb) checks against the same report name persisted by [`ReportGenerator`](./app/services/report_generator.rb).
   - The scheduler regression test creates a report through the generator and verifies that another job is not enqueued that day.

5. **Run the Rails tests in CI — implemented**
   - [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) starts PostgreSQL and runs both `bin/rails test` and `bin/rails test:system`.
   - [`config/ci.rb`](./config/ci.rb) includes the Rails and system test commands.

### P2 — Important behavior and validation

6. **Honor each user’s daily reminder time — implemented**
   - [`DailyReminderJob`](./app/jobs/daily_reminder_job.rb) is dispatched every minute in development and production, and queues enabled users with study plans once their configured local time arrives.
   - The job uses each user's timezone, catches up when a configured time is skipped during spring-forward, and checks for an existing reminder on that user's local date to avoid sending twice during fall-back.
   - [`daily_reminder_job_test.rb`](./test/jobs/daily_reminder_job_test.rb) covers per-user times across time zones, disabled reminders, multiple plans, and both DST transitions.

7. **Validate study preference JSON — implemented**
   - [`User`](./app/models/user.rb) normalizes partial JSON preferences against defaults and validates weekdays, `HH:MM` values, and boolean settings.
   - Controller tests cover malformed values and partial updates that omit nested keys.

8. **Remove the unused notification detail route — implemented**
   - The unused show action and route are removed; a controller test verifies that notification detail URLs return 404.

9. **Enforce the active-session invariant under concurrent requests — implemented**
   - A partial unique index enforces one unfinished session per topic in PostgreSQL, and the create action renders a validation response if a concurrent insert wins the race.
   - A model test verifies the database rejects a duplicate even when model validation is bypassed.

### P3 — Hardening and scale

10. **Add upload constraints — implemented**
    - [`User`](./app/models/user.rb) limits avatars to supported image formats and 5 MB.
    - [`Topic`](./app/models/topic.rb) limits resources to supported document/image/text formats, 20 MB per file, and 10 files.
    - Forms describe the limits and constrain the file-picker types; model tests cover rejected types, oversized files, and valid uploads.

11. **Finish setup and operations documentation — implemented**
    - [`README.md`](./README.md) documents requirements, setup, database migrations, production secrets, storage and queue behavior, recurring jobs, test commands, and Chrome/Selenium requirements.

## Remaining operational verification

The production schedules and queue-supervisor setting are covered by configuration tests, but successful processing should still be confirmed in a production-like deployment.
