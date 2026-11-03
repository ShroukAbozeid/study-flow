require "test_helper"
require "yaml"

class RecurringJobsConfigurationTest < ActiveSupport::TestCase
  test "development and production schedule the daily reminder dispatcher every minute" do
    recurring_jobs = YAML.safe_load_file(Rails.root.join("config/recurring.yml"))

    %w[development production].each do |environment|
      assert_equal "DailyReminderJob", recurring_jobs.dig(environment, "daily_reminder", "class")
      assert_equal "every minute", recurring_jobs.dig(environment, "daily_reminder", "schedule")
    end
  end

  test "production schedules the weekly report scheduler" do
    recurring_jobs = YAML.safe_load_file(Rails.root.join("config/recurring.yml"))
    deploy_config = YAML.safe_load_file(Rails.root.join("config/deploy.yml"))

    assert_equal "ReportSchedulerJob", recurring_jobs.dig("production", "report_scheduler", "class")
    assert_equal "every hour", recurring_jobs.dig("production", "report_scheduler", "schedule")
    assert_equal true, deploy_config.dig("env", "clear", "SOLID_QUEUE_IN_PUMA")
  end
end
