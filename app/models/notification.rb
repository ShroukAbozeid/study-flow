class Notification < ApplicationRecord
  belongs_to :user

  validates :title, :content, presence: true
  scope :newest_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(read: false) }

  after_create_commit :broadcast_unread_count
  after_update_commit :broadcast_unread_count

  private

  def broadcast_unread_count
    Turbo::StreamsChannel.broadcast_replace_to(
      user,
      :unread_notifications_count,
      target: "unread_notifications_count",
      partial: "notifications/unread_count",
      locals: { count: user.notifications.unread.count }
    )
  end
end
