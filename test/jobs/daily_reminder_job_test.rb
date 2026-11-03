require "test_helper"

class DailyReminderJobTest < ActiveJob::TestCase
  test "enqueues reminders only for users with plans and reminders enabled" do
    users(:two).update!(
      study_preferences: users(:two).study_preferences.merge(
        "daily_reminder_notification" => { "enabled" => false, "time" => "08:00" }
      )
    )

    travel_to Time.utc(2026, 11, 2, 8, 0) do
      assert_enqueued_with(job: NotificationJob,
                           args: [ "Notification::DailyReminder", users(:one).id ]) do
        DailyReminderJob.perform_now
      end

      assert_equal 1, enqueued_jobs.count { |job| job[:job] == NotificationJob }
    end
  end

  test "enqueues only one reminder for a user with multiple study plans" do
    user = users(:one)
    user.study_plans.create!(name: "Another study plan")

    travel_to Time.utc(2026, 11, 2, 8, 0) do
      DailyReminderJob.perform_now

      reminder_jobs = enqueued_jobs.select { |job| job[:job] == NotificationJob }
      user_ids = reminder_jobs.map { |job| job[:args].last }

      assert_equal 1, user_ids.count(user.id)
    end
  end

  test "enqueues reminders according to each user's local time" do
    update_reminder(users(:one), time: "08:15")
    users(:one).update!(time_zone: "Eastern Time (US & Canada)")
    update_reminder(users(:two), time: "13:15")
    users(:two).update!(time_zone: "London")

    travel_to Time.utc(2026, 11, 2, 13, 14) do
      assert_no_enqueued_jobs(only: NotificationJob) do
        DailyReminderJob.perform_now
      end
    end

    travel_to Time.utc(2026, 11, 2, 13, 15) do
      DailyReminderJob.perform_now

      reminder_user_ids = enqueued_jobs
        .select { |job| job[:job] == NotificationJob }
        .map { |job| job[:args].last }

      assert_equal [ users(:one).id, users(:two).id ].sort, reminder_user_ids.sort
    end
  end

  test "sends reminders after a configured time skipped by the spring DST transition" do
    user = users(:one)
    user.update!(time_zone: "Eastern Time (US & Canada)")
    update_reminder(user, time: "02:30")
    update_reminder(users(:two), enabled: false)

    travel_to Time.utc(2026, 3, 8, 7, 0) do
      assert_enqueued_with(job: NotificationJob, args: [ "Notification::DailyReminder", user.id ]) do
        DailyReminderJob.perform_now
      end
    end
  end

  test "does not send a second reminder during the repeated fall DST hour" do
    user = users(:one)
    user.update!(time_zone: "Eastern Time (US & Canada)")
    update_reminder(user, time: "01:30")
    update_reminder(users(:two), enabled: false)

    travel_to Time.utc(2026, 11, 1, 5, 30) do
      DailyReminderJob.perform_now
      assert_equal 1, enqueued_jobs.count { |job| job[:job] == NotificationJob }
      NotificationJob.perform_now("Notification::DailyReminder", user.id)
    end

    travel_to Time.utc(2026, 11, 1, 6, 30) do
      assert_no_enqueued_jobs(only: NotificationJob) do
        DailyReminderJob.perform_now
      end
    end
  end

  private

  def update_reminder(user, enabled: true, time: "08:00")
    user.update!(
      study_preferences: user.study_preferences.merge(
        "daily_reminder_notification" => { "enabled" => enabled, "time" => time }
      )
    )
  end
end
