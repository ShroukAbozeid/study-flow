class StudyPlan < ApplicationRecord
  belongs_to :user
  has_many :topics, dependent: :destroy

  validates :name, presence: true
end
