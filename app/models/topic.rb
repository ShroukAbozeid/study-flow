class Topic < ApplicationRecord
  RESOURCE_CONTENT_TYPES = %w[
    application/pdf
    application/msword
    application/vnd.ms-excel
    application/vnd.ms-powerpoint
    application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.openxmlformats-officedocument.presentationml.presentation
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
    image/gif
    image/jpeg
    image/png
    image/webp
    text/plain
  ].freeze
  MAX_RESOURCE_SIZE = 20.megabytes
  MAX_RESOURCES = 10

  belongs_to :study_plan
  has_many :study_sessions, dependent: :destroy
  has_many_attached :resources

  validates :name, :estimated_hours, presence: true
  validates :estimated_hours, numericality: { greater_than: 0 }
  validate :valid_resources

  before_validation :set_position, on: :create

  def set_position
    self.position = (study_plan.topics.maximum(:position) || 0) + 1
  end

  private

  def valid_resources
    if resources.attachments.size > MAX_RESOURCES
      errors.add(:resources, "cannot include more than #{MAX_RESOURCES} files")
    end

    resources.each do |resource|
      errors.add(:resources, "#{resource.filename} has an unsupported file type") unless RESOURCE_CONTENT_TYPES.include?(resource.blob.content_type)
      errors.add(:resources, "#{resource.filename} must be 20 MB or smaller") if resource.blob.byte_size > MAX_RESOURCE_SIZE
    end
  end
end
