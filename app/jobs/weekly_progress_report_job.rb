class WeeklyProgressReportJob < ApplicationJob
  queue_as :default

  def perform(user)
    report = ReportGenerator.new(user:, name: "weekly_progress").call
    UserMailer.with(user:, report:).report_email.deliver_now
  end
end
