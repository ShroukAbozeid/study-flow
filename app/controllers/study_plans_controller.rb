class StudyPlansController < ApplicationController
  def new
    @study_plan = Current.user.study_plans.build
  end

  def create
    @study_plan = Current.user.study_plans.build(study_plan_params)
    if @study_plan.save
      redirect_to dashboard_show_path, notice: "Study plan created successfully."
    else
      render :new
    end
  end

  def edit
    @study_plan = Current.user.study_plans.find(params[:id])
  end

  def update
    @study_plan = Current.user.study_plans.find(params[:id])
    if @study_plan.update(study_plan_params)
      redirect_to dashboard_show_path, notice: "Study plan updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @study_plan = Current.user.study_plans.find(params[:id])
    @study_plan.destroy
    redirect_to dashboard_show_path, notice: "Study plan deleted successfully."
  end

  private

  def study_plan_params
    params.require(:study_plan).permit(:name, :description, :daily_hour)
  end
end
