require "test_helper"
require "yaml"

class RecurringJobsConfigurationTest < ActiveSupport::TestCase
  test "production schedules daily reminders" do
    recurring_jobs = YAML.safe_load_file(Rails.root.join("config/recurring.yml"))

    assert_equal "DailyReminderJob", recurring_jobs.dig("production", "daily_reminder", "class")
    assert_equal "every day at 8am", recurring_jobs.dig("production", "daily_reminder", "schedule")
  end

  test "production schedules the weekly report scheduler" do
    recurring_jobs = YAML.safe_load_file(Rails.root.join("config/recurring.yml"))

    assert_equal "ReportSchedulerJob", recurring_jobs.dig("production", "report_scheduler", "class")
    assert_equal "every hour", recurring_jobs.dig("production", "report_scheduler", "schedule")
  end
end
