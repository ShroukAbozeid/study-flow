class DashboardController < ApplicationController
  def show
    @study_plans = current_user.study_plans
    @current_study_streak = current_user.current_study_streak
    @ongoing_study_sessions = StudySession.of_user(current_user).active.includes(topic: :study_plan)
    @completed_today_sessions = StudySession.of_user(current_user).completed_at(Time.zone.today).includes(topic: :study_plan)
  end
end
