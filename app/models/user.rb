class User < ApplicationRecord
  has_secure_password

  AVATAR_CONTENT_TYPES = %w[image/png image/jpeg image/gif image/webp].freeze
  MAX_AVATAR_SIZE = 5.megabytes

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

  WEEK_DAYS = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
  has_one_attached :avatar

  has_many :sessions, dependent: :destroy
  has_many :study_plans, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :topics, through: :study_plans
  has_many :study_sessions, through: :topics
  has_many :reports, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :time_zone, presence: true, inclusion: { in: ActiveSupport::TimeZone.all.map(&:name) }
  before_validation :normalize_study_preferences
  validate :valid_weekly_progress_report_day, :valid_week_start_day,
           :valid_weekly_progress_report_time, :valid_daily_reminder_time,
           :valid_daily_reminder_enabled, :valid_weekly_progress_report_enabled
  validate :valid_avatar

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def preference(section, key)
    settings = if respond_to?(section)
      public_send(section)
    else
      study_preferences&.with_indifferent_access&.[](section)
    end

    (settings || {}).with_indifferent_access[key]
  end

  def current_study_streak
    active_dates = study_sessions.pluck(:started_at, :finished_at).flat_map do |started_at, finished_at|
      [ started_at, finished_at ].compact.map { |timestamp| timestamp.in_time_zone(time_zone).to_date }
    end.to_set

    today = Time.current.in_time_zone(time_zone).to_date
    streak_date = active_dates.include?(today) ? today : today.yesterday
    return 0 unless active_dates.include?(streak_date)

    streak = 0
    while active_dates.include?(streak_date)
      streak += 1
      streak_date -= 1.day
    end
    streak
  end

  def cached_current_study_streak
    Rails.cache.fetch(current_study_streak_cache_key, expires_in: 2.days) { current_study_streak }
  end

  def refresh_current_study_streak_cache
    streak = current_study_streak
    Rails.cache.write(current_study_streak_cache_key, streak, expires_in: 2.days)
    streak
  end

  private

  def current_study_streak_cache_key
    "users/#{id}/current_study_streak/#{time_zone}/#{Time.current.in_time_zone(time_zone).to_date}"
  end

  def normalize_study_preferences
    unless study_preferences.is_a?(Hash)
      errors.add(:study_preferences, :invalid_format)
      self.study_preferences = DEFAULT_STUDY_PREFERENCES.deep_stringify_keys
      return
    end

    preferences = DEFAULT_STUDY_PREFERENCES.deep_stringify_keys.deep_merge(study_preferences.deep_stringify_keys)
    %w[daily_reminder_notification weekly_progress_report].each do |section|
      next unless preferences[section].is_a?(Hash)

      preferences[section]["enabled"] =
        case preferences[section]["enabled"]
        when "1", "true" then true
        when "0", "false" then false
        else preferences[section]["enabled"]
        end
    end
    self.study_preferences = preferences
  end

  def valid_avatar
    return unless avatar.attached?

    unless AVATAR_CONTENT_TYPES.include?(avatar.blob.content_type)
      errors.add(:avatar, :invalid_avatar_type)
    end
    errors.add(:avatar, :invalid_avatar_size) if avatar.blob.byte_size > MAX_AVATAR_SIZE
  end

  def valid_weekly_progress_report_day
    return if preference_section("weekly_progress_report")["day"].in?(WEEK_DAYS)

    errors.add(:study_preferences, :invalid_weekly_report_day)
  end

  def valid_week_start_day
    return if study_preferences["week_start_day"].in?(WEEK_DAYS)

    errors.add(:study_preferences, :invalid_week_start_day)
  end

  def valid_weekly_progress_report_time
    return if valid_preference_time?(preference_section("weekly_progress_report")["time"])

    errors.add(:study_preferences, :invalid_weekly_report_time)
  end

  def valid_daily_reminder_time
    return if valid_preference_time?(preference_section("daily_reminder_notification")["time"])

    errors.add(:study_preferences, :invalid_daily_reminder_time)
  end

  def valid_daily_reminder_enabled
    return if [ true, false ].include?(preference_section("daily_reminder_notification")["enabled"])

    errors.add(:study_preferences, :invalid_daily_reminder_enabled)
  end

  def valid_weekly_progress_report_enabled
    return if [ true, false ].include?(preference_section("weekly_progress_report")["enabled"])

    errors.add(:study_preferences, :invalid_weekly_report_enabled)
  end

  def preference_section(section)
    value = study_preferences[section]
    value.is_a?(Hash) ? value : {}
  end

  def valid_preference_time?(value)
    value.is_a?(String) && value.match?(/\A(?:[01]\d|2[0-3]):[0-5]\d\z/)
  end
end
