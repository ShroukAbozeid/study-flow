module Reports
  class WeeklyProgress < Report
    NAME = "Weekly Progress"
    COLUMNS = %w[completed started started_and_completed_this_week].freeze
    FILE_NAME = "weekly_progress".freeze

    def self.generate(user)
      start_date = Date.current.beginning_of_week.beginning_of_day
      end_date = Date.current.end_of_week.end_of_day
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
