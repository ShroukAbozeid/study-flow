require "test_helper"

class NotificationJobTest < ActiveJob::TestCase
  test "creates a notification and delivers its email" do
    assert_difference("Notification.count", 1) do
      assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
        NotificationJob.perform_now("Notification::DailyReminder", users(:one).id)
      end
    end

    notification = Notification.order(:id).last
    assert_equal users(:one), notification.user
    assert_equal "Daily Reminder", notification.title
    assert_includes notification.content, "You have 1 study plans."
    assert_includes ActionMailer::Base.deliveries.last.body.encoded, "You have 1 study plans."
  end
end
