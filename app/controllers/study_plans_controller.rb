class StudyPlansController < ApplicationController
  def show
    @study_plan = current_user.study_plans.find(params.expect(:id))
  end
  def new
    @study_plan = current_user.study_plans.build
  end

  def edit
    @study_plan = current_user.study_plans.find(params.expect(:id))
  end
  def create
    @study_plan = current_user.study_plans.build(study_plan_params)
    if @study_plan.save!
      redirect_to dashboard_show_path, notice: t("controllers.study_plans.created")
    else
      render :new
    end
  end


  def update
    @study_plan = current_user.study_plans.find(params.expect(:id))
    if @study_plan.update(study_plan_params)
      redirect_to study_plan_path(@study_plan), notice: t("controllers.study_plans.updated")
    else
      render :edit
    end
  end

  def destroy
    @study_plan = current_user.study_plans.find(params.expect(:id))
    @study_plan.destroy
    redirect_to dashboard_show_path, notice: t("controllers.study_plans.deleted")
  end

  private

  def study_plan_params
    params.expect(study_plan: [ :name, :description, :daily_hour ])
  end
end
