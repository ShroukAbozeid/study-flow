class DashboardController < ApplicationController
  def show
    @study_plans = Current.user.study_plans
    @ongoing_study_sessions = StudySession.of_user(Current.user).active.includes(topic: :study_plan)
    @completed_today_sessions = StudySession.of_user(Current.user).completed_at(Date.today).includes(topic: :study_plan)
  end
end
