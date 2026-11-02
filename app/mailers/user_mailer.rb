class UserMailer < ApplicationMailer
  def notification_email
    @notification = params[:notification]
    mail(to: @notification.user.email_address, subject: @notification.title)
  end

  def report_email
    @user = params[:user]
    @report = params[:report]
    attachments[@report.file.filename.to_s] = @report.file.download
    mail(to: @user.email_address, subject: I18n.t("mailers.user.report_email.subject"))
  end
end
