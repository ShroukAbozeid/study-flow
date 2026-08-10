class Topic < ApplicationRecord
  belongs_to :study_plan

  validates :name, :estimated_hours, presence: true
  validates :estimated_hours, numericality: { greater_than: 0 }

  before_validation :set_position, on: :create

  def set_position
    self.position = (study_plan.topics.maximum(:position) || 0) + 1
  end
end
