require "test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  test "enqueues reminders only for users with plans and reminders enabled" do
    users(:two).update!(
      study_preferences: users(:two).study_preferences.merge(
        "daily_reminder_notification" => { "enabled" => false, "time" => "08:00" }
      )
    )

    assert_enqueued_with(job: NotificationJob,
                         args: [ "Notification::DailyReminder", users(:one).id ]) do
      DailyReminderJob.perform_now
    end

    assert_equal 1, enqueued_jobs.count { |job| job[:job] == NotificationJob }
  end

  test "enqueues only one reminder for a user with multiple study plans" do
    user = users(:one)
    user.study_plans.create!(name: "Another study plan")

    DailyReminderJob.perform_now

    reminder_jobs = enqueued_jobs.select { |job| job[:job] == NotificationJob }
    user_ids = reminder_jobs.map { |job| job[:args].last }

    assert_equal 1, user_ids.count(user.id)
  end
end
