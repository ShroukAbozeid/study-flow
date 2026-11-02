module Reports
  class WeeklyProgress < Report
    FILE_NAME = "weekly_progress".freeze

    def self.report_name
      I18n.t("models.reports.weekly_progress.name")
    end

    def self.columns
      I18n.t("models.reports.weekly_progress.columns")
    end

    def self.generate(user)
      week_start = (user.study_preferences["week_start_day"] || "Monday").downcase.to_sym
      user_zone = ActiveSupport::TimeZone[user.time_zone]
      start_date = user_zone.now.beginning_of_week(week_start).beginning_of_day
      start_date -= 1.week if start_date.to_date == user_zone.today
      end_date = start_date.end_of_week(week_start).end_of_day

      user_study_sessions = StudySession.where(topic: user.topics)
      completed_this_week = user_study_sessions.where(finished_at: start_date..end_date)
      started_this_week = user_study_sessions.where(created_at: start_date..end_date)
      started_and_completed_this_week = started_this_week & completed_this_week
      {
        completed: completed_this_week.count,
        started: started_this_week.count,
        started_and_completed_this_week: started_and_completed_this_week.count
      }
    end
  end
end
