class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      NotificationJob.perform_later("Notification::DailyReminder", user.id)
    end
  end
end
