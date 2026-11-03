class NotificationsController < ApplicationController
  def index
    @notifications = current_user.notifications.newest_first
  end

  def mark_read
    @notification = current_user.notifications.find(params.expect(:id))
    @notification.update(read: true)
  end

  def mark_unread
    @notification = current_user.notifications.find(params.expect(:id))
    @notification.update(read: false)
  end

  def mark_all_read
    current_user.notifications.unread.update_all(read: true) # rubocop:disable Rails/SkipsModelValidations
    redirect_to notifications_path, notice: t("controllers.notifications.all_marked_read")
  end
end
