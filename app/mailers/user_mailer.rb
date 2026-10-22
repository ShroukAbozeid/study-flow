class UserMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    mail(to: @notification.user.email_address, subject: @notification.title)
  end
end
