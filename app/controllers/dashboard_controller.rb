class DashboardController < ApplicationController
  def show
    @study_plans = Current.user.study_plans
  end
end
