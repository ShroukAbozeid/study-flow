class NotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_class, user_id)
    notification = notification_class.constantize.create_for_user!(user: User.find(user_id))
    deliver_notification(notification)
  end

  def deliver_notification(notification)
    # Implement the logic to deliver the notification to the user
    # For example, you can send an email, push notification, etc.
    # You can use ActionMailer or any other notification service here
    UserMailer.with(notification:).notification_email.deliver_now
  end
end
