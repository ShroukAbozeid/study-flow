class NotificationsController < ApplicationController
  def index
    @notifications = Current.user.notifications.newest_first
  end

  def show
    @notification = Current.user.notifications.find(params[:id])
  end

  def mark_read
    @notification = Current.user.notifications.find(params[:id])
    @notification.update(read: true)
  end

  def mark_unread
    @notification = Current.user.notifications.find(params[:id])
    @notification.update(read: false)
  end

  def mark_all_read
    Current.user.notifications.unread.update_all(read: true)
    redirect_to notifications_path, notice: "All notifications marked as read."
  end
end
