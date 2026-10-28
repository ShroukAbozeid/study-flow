class ReportSchedulerJob < ApplicationJob
  queue_as :default

  def perform
    User.where("study_preferences -> 'weekly_progress_report' ->> 'enabled' = ?", "true")
    .find_each do |user|
      WeeklyProgressReportJob.perform_later(user.id) if report_is_due?(user)
    end
  end

  def report_is_due?(user)
    zone = ActiveSupport::TimeZone[user.time_zone]
    day = user.preference(:weekly_progress_report, :day)
    time = user.preference(:weekly_progress_report, :time)

    date = zone.today
    return false unless date.strftime("%A") == day # report day is not today

    report_time = zone.local(date.year, date.month, date.day, time.to_i, time.split(":")[1].to_i)
    return false if zone.now < report_time # report time has not yet arrived

    last_report = user.reports.where(name: "weekly_progress").order(created_at: :desc).first
    return false if last_report && last_report.created_at.in_time_zone(zone).to_date == date # report has already been sent today

    true
  end
end
