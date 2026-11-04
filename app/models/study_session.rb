class StudySession < ApplicationRecord
  has_rich_text :notes

  belongs_to :topic
  has_one :study_plan, through: :topic

  validate :only_one_session_active, on: :create

  scope :active, -> { where(finished_at: nil) }
  scope :completed_at, ->(date) { where(finished_at: date.all_day) }
  scope :of_user, ->(user) { joins(topic: :study_plan).where(study_plans: { user_id: user.id }) }


  after_create_commit :broadcast_add_to_active_sessions
  after_update_commit :broadcast_active_sessions, :broadcast_completed_sessions, if: :saved_change_to_finished_at?
  after_update_commit :broadcast_updated_session
  after_commit :broadcast_study_streak, if: :study_streak_changed?

  delegate :user, to: :study_plan

  private

  def broadcast_updated_session
    Turbo::StreamsChannel.broadcast_replace_to(
      user,
      :sessions,
      target: "study_session_#{id}",
      partial: "study_sessions/session",
      locals: { session: self }
    )
  end

  def broadcast_add_to_active_sessions
      Turbo::StreamsChannel.broadcast_append_to(
        user,
        :active_sessions,
        target: "active_sessions",
        partial: "dashboard/active_session",
        locals: { study_session: self }
      )
  end

  def broadcast_study_streak
    streak = user.refresh_current_study_streak_cache
    Turbo::StreamsChannel.broadcast_replace_to(
      user,
      :study_streak,
      target: "study_streak",
      partial: "dashboard/study_streak",
      locals: { streak: }
    )
  end

  def broadcast_active_sessions
      Turbo::StreamsChannel.broadcast_remove_to(
      user,
      :active_sessions,
      target: "active_study_session_#{id}"
    )
  end

  def broadcast_completed_sessions
    Turbo::StreamsChannel.broadcast_append_to(
      user,
      :completed_sessions,
      target: "completed_sessions",
      partial: "dashboard/completed_session",
      locals: { study_session: self }
    )
  end

  def only_one_session_active
    return if topic.study_sessions.active.empty?

    errors.add(:base, I18n.t("models.study_session.errors.already_active"))
  end

  def study_streak_changed?
    previously_new_record? || saved_change_to_finished_at? || destroyed?
  end
end
