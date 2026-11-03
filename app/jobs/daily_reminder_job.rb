class DailyReminderJob < ApplicationJob
  queue_as :default

  def perform
    User.where.associated(:study_plans)
        .distinct
        .where("study_preferences -> 'daily_reminder_notification' ->> 'enabled' = ?", "true")
        .find_each do |user|
      next unless reminder_is_due?(user)

      NotificationJob.perform_later("Notification::DailyReminder", user.id)
    end
  end

  private

  def reminder_is_due?(user)
    zone = ActiveSupport::TimeZone[user.time_zone]
    time = user.preference(:daily_reminder_notification, :time).to_s
    unless zone && time.match?(/\A(?:[01]\d|2[0-3]):[0-5]\d\z/)
      Rails.logger.warn("Skipping daily reminder for user #{user.id}: invalid time zone or reminder time")
      return false
    end

    local_now = zone.now
    return false if local_now.strftime("%H:%M") < time

    user.notifications.where(title: Notification::DailyReminder.title)
        .where(created_at: local_now.all_day)
        .none?
  end
end
