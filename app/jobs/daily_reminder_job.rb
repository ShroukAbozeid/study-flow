class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.where.associated(:study_plans)
        .distinct
        .where("study_preferences -> 'daily_reminder_notification' ->> 'enabled' = ?", "true")
        .find_each do |user|
      NotificationJob.perform_later("Notification::DailyReminder", user.id)
    end
  end
end
