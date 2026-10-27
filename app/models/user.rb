class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :study_plans, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :topics, through: :study_plans
  has_many :study_sessions, through: :topics
  has_many :reports, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
