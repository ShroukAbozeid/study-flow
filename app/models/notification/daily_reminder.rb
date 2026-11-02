class Notification::DailyReminder < Notification
  def self.title
    I18n.t("models.notifications.daily_reminder.title")
  end

  def self.content(user:)
    return unless user&.study_plans.exists?

    I18n.t(
      "models.notifications.daily_reminder.content",
      study_plan_count: user.study_plans.count,
      active_session_count: user.study_sessions.active.count
    )
  end

  def self.create_for_user!(user:)
    create!(user:, title:, content: content(user:))
  end
end
