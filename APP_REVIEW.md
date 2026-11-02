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

The README is still the Rails-generated starter text; it does not yet explain setup, required services, scheduled jobs, or how to run browser tests.

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

The dashboard loads the current user’s plans and their active and recently completed sessions. Study-plan reads and writes are scoped through `Current.user`. Topic and study-session actions use unscoped record lookups; this inconsistency is a priority issue below.

Study sessions broadcast changes through Turbo Streams. A model validation prevents a second active session for the same topic during ordinary sequential requests.

### Notifications and preferences

Notifications can be listed, shown, marked read/unread, or bulk-marked read. The unread count is broadcast after notification creation and updates. Profile and preference settings are updated through separate controllers.

### Reminders and reports

[`config/recurring.yml`](./config/recurring.yml) defines daily reminder and hourly report-scheduler entries for development. The daily job queues reminder jobs for eligible users with study plans. The report scheduler checks each eligible user’s configured day/time and queues the weekly report job. The report job generates a CSV, attaches it to a report, and emails it.

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

The current tests do not cover all scenarios listed below. The system-test base uses headless Chrome, so executing browser tests requires Chrome and a compatible Selenium setup. The current GitHub Actions workflow and [`config/ci.rb`](./config/ci.rb) run lint/security checks but do not invoke the Rails test suite.

## Prioritized work

Priority meanings: **P1** = high impact; address before relying on the affected feature or broadening access. **P2** = important functional reliability or user-facing completeness. **P3** = hardening and scale follow-up.

### P1 — High priority

1. **Enforce ownership for topics and study sessions**
   - [`TopicsController`](./app/controllers/topics_controller.rb) uses `Topic.find` for edit/update/delete and accepts `study_plan_id` directly when creating a topic.
   - [`StudySessionsController`](./app/controllers/study_sessions_controller.rb) uses `StudySession.find` for read/update/complete/delete and accepts `topic_id` directly when creating a session.
   - These paths do not constrain the target plan/topic/session to `Current.user`, unlike the study-plan and notification paths. This can expose or modify another user’s records.
   - **Handle:** scope every read and mutation through the current user’s plans/topics/sessions, and derive parent ownership from the scoped association rather than trusting submitted foreign keys.
   - **Add tests:** cross-user show/edit/update/delete/complete requests and attempts to create a topic/session under another user’s parent record must be rejected without changing data.

2. **Complete password-reset token support**
   - [`PasswordsController`](./app/controllers/passwords_controller.rb) looks up users by `password_reset_token`, but [`User`](./app/models/user.rb) does not declare a token generator and the users schema has no corresponding persisted column.
   - The mailer test stubs token methods, so it only verifies template rendering and does not establish that the real user model can issue or validate a reset token.
   - **Handle:** implement Rails token generation with expiration and bind token validity to password changes; make invalid/expired tokens return a deliberate response.
   - **Add tests:** request, valid token display, successful password change, mismatched confirmation, invalid/expired token, and invalidation of existing sessions after reset.

3. **Verify recurring reminders and reports in production**
   - [`config/recurring.yml`](./config/recurring.yml) now includes daily reminders and the report scheduler in `production`, in addition to the Solid Queue cleanup task.
   - Regression tests in [`recurring_jobs_configuration_test.rb`](./test/jobs/recurring_jobs_configuration_test.rb) check that both schedules are present.
   - **Remaining:** verify the production queue supervisor registers and processes these recurring tasks in a production-like deployment.

4. **Prevent duplicate weekly reports**
   - [`ReportSchedulerJob`](./app/jobs/report_scheduler_job.rb) now checks against `Reports::WeeklyProgress::NAME`, the same name [`ReportGenerator`](./app/services/report_generator.rb) persists.
   - The scheduler regression test now generates the report through `ReportGenerator` before checking that another job is not enqueued.
   - **Remaining:** retain this test when changing report naming, persistence, or scheduler behavior.

5. **Run the Rails tests in CI**
   - [`.github/workflows/ci.yml`](./.github/workflows/ci.yml) runs Brakeman, Bundler Audit, Importmap audit, and RuboCop, but no test command.
   - [`config/ci.rb`](./config/ci.rb) likewise does not include `bin/rails test`.
   - **Handle:** add a CI test step for the request/model/job/mailer/integration suites. Add a browser-capable job or document a separate supported system-test runner so system tests are not silently omitted.

### P2 — Important behavior and validation

6. **Honor each user’s daily reminder time**
   - `daily_reminder_notification.time` is stored and editable, but [`DailyReminderJob`](./app/jobs/daily_reminder_job.rb) only checks the enabled flag. The recurring task runs once globally at 8am in development.
   - **Handle:** schedule per-user deliveries at their configured local time, including timezone and daylight-saving transitions, or explicitly remove/rename the unused setting if a global send time is intended.
   - **Add tests:** users in different time zones, configured times, disabled reminders, and daylight-saving boundaries.

7. **Validate study preference JSON**
   - [`Settings::StudyPreferencesController`](./app/controllers/settings/study_preferences_controller.rb) permits preference values but does not validate day names, time formats, or enabled values.
   - [`ReportSchedulerJob`](./app/jobs/report_scheduler_job.rb) parses stored time strings; malformed or missing values can cause failed jobs or prevent reports from running as intended.
   - **Handle:** validate allowed weekdays, `HH:MM` times, and boolean settings while preserving defaults for omitted values.
   - **Add tests:** malformed time, missing nested keys, unexpected day, and partial preference updates.

8. **Implement the notification detail page**
   - The notification show route and action exist, but [`app/views/notifications/show.html.erb`](./app/views/notifications/show.html.erb) is still a generated placeholder.
   - **Handle:** display the selected notification and provide appropriate navigation/read-state behavior, or remove the unused show route.
   - **Add test:** assert meaningful notification content in the rendered page, not only a successful HTTP status.

9. **Enforce the active-session invariant under concurrent requests**
   - The “one active session per topic” rule is an application-level validation in [`StudySession`](./app/models/study_session.rb). Two concurrent create requests can both pass the validation before either commits.
   - **Handle:** enforce the invariant at the persistence layer where practical (for PostgreSQL, consider a partial unique index on active rows) and handle the resulting conflict cleanly.
   - **Add test:** verify concurrent or database-conflict behavior in addition to the current sequential validation test.

### P3 — Hardening and scale

10. **Add upload constraints**
    - User avatars and topic resources use Active Storage, but model-level file type and size constraints are not defined.
    - **Handle:** set acceptable content types and size limits and present validation errors in the upload forms.
    - **Add tests:** disallowed types, oversized files, and valid uploads.

11. **Finish setup and operations documentation**
    - [`README.md`](./README.md) is Rails starter text.
    - **Handle:** document Ruby/PostgreSQL requirements, setup and migrations, environment variables, storage/queue services, recurring-job setup, test commands, and the Chrome requirement for system tests.

## Suggested order

1. Close ownership boundaries and complete password reset.
2. Fix weekly-report deduplication and enable production schedules.
3. Add CI test execution and run browser tests in an environment with Chrome.
4. Validate preferences and honor per-user reminder times.
5. Complete notification details and then address persistence-level concurrency and upload hardening.
