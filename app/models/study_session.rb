class StudySession < ApplicationRecord
  belongs_to :topic

  validate :only_one_session_active, on: :create

  scope :active, -> { where(finished_at: nil) }

  def only_one_session_active
    return if topic.study_sessions.active.empty?
    errors.add(:base, "There is already an active study session for this topic.")
  end
end
