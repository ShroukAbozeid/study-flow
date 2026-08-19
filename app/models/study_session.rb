class StudySession < ApplicationRecord
  belongs_to :topic

  validate :only_one_session_active, on: :create

  scope :active, -> { where(finished_at: nil) }
  scope :completed_at, ->(date) { where(finished_at: date.beginning_of_day..date.end_of_day) }
  scope :of_user, ->(user) { joins(topic: :study_plan).where(study_plans: { user_id: user.id }) }

  def only_one_session_active
    return if topic.study_sessions.active.empty?
    errors.add(:base, "There is already an active study session for this topic.")
  end
end
