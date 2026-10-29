class User < ApplicationRecord
  DEFAULT_STUDY_PREFERENCES = {
    daily_reminder_notification: {
       enabled: true,
       time: "08:00"
     },
     weekly_progress_report: {
       enabled: true,
       day: "Sunday",
       time: "21:00"
     },
     week_start_day: "Monday"
  }

  has_secure_password
  has_one_attached :avatar

  has_many :sessions, dependent: :destroy
  has_many :study_plans, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :topics, through: :study_plans
  has_many :study_sessions, through: :topics
  has_many :reports, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def preference(section, key)
    (public_send(section) || {}).with_indifferent_access[key]
  end
end
