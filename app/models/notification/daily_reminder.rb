class Notification::DailyReminder < Notification
  def self.title
    "Daily Reminder"
  end

  def self.content(user:)
    return unless user&.study_plans.exists?

    <<-TEXT
    Don't forget to check your study plan today!
    You have #{user.study_plans.count} study plans.
    and #{user.study_sessions.active.count} active sessions"
    TEXT
  end

  def self.create_for_user!(user:)
    create!(user:, title:, content: content(user:))
  end
end
