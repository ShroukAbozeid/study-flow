# Study Flow

Study Flow is a Rails app for organizing study plans, tracking study sessions, and receiving reminders and weekly progress reports.

## Requirements

- Ruby version in [`.ruby-version`](./.ruby-version)
- PostgreSQL
- Google Chrome and a compatible Selenium setup to run browser system tests

## Local setup

1. Install PostgreSQL and make sure your local PostgreSQL role can create databases.
2. Run `bin/setup` to install Ruby dependencies and prepare the databases.
3. Run `bin/dev` to start the development server and asset watcher.

By default, development uses the local PostgreSQL role. Set `DATABASE_URL` if your database is configured differently. Run `bin/rails db:prepare` after pulling migrations; use `bin/rails db:seed` to load seed data.

## Background jobs and scheduled work

Active Job uses Solid Queue in production. The development and production schedules in [`config/recurring.yml`](./config/recurring.yml) dispatch daily reminders every minute and check for weekly reports hourly. Each dispatcher applies the user's configured local time and timezone.

The Kamal configuration runs the Solid Queue supervisor in the Puma process with `SOLID_QUEUE_IN_PUMA=true`. If deploying multiple web servers, configure a dedicated job server instead of starting a supervisor on every web server. Ensure the queue database is migrated along with the primary database.

Production deployment requires `RAILS_MASTER_KEY` and `STUDY_FLOW_DATABASE_PASSWORD`. Configure SMTP credentials in Rails credentials before enabling email delivery. Production file uploads use the configured local Active Storage service; mount and back up the storage volume as configured in `config/deploy.yml`.

## Tests and checks

- `bin/rails test` runs model, controller, job, mailer, and integration tests.
- `bin/rails test:system` runs browser tests and requires Chrome/Selenium.
- `bin/ci` runs the project CI steps, including the system tests.

GitHub Actions runs the Rails suite and browser system tests against PostgreSQL using local headless Chrome. In WSL, `bin/rails test:system` connects to ChromeDriver running on the Windows host, using the first nameserver in `/etc/resolv.conf` on port `9515`. Set `CHROMEDRIVER_URL` if the ChromeDriver is reachable at a different URL.
