class TopicsController < ApplicationController
  before_action :find_study_plan!, only: %i[new create]
  before_action :find_topic!, only: %i[edit update destroy]

  def new
    @topic = @study_plan.topics.new
  end

  def edit
  end

  def create
    @topic = @study_plan.topics.new(topic_params)

    if @topic.save
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = t("controllers.topics.created") }
        format.html { redirect_to edit_study_plan_path(@study_plan), notice: t("controllers.topics.created") }
      end
    else
      flash[:alert] = @topic.errors.full_messages.join(", ")
      render :new, status: :unprocessable_content
    end
  end


  def update
    if @topic.update(topic_params)
       respond_to do |format|
        format.turbo_stream { flash.now[:notice] = t("controllers.topics.updated") }
        format.html { redirect_to edit_study_plan_path(@topic.study_plan), notice: t("controllers.topics.updated") }
      end
    else
      flash[:alert] = @topic.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @topic.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = t("controllers.topics.deleted") }
      format.html { redirect_to edit_study_plan_path(@topic.study_plan), notice: t("controllers.topics.deleted") }
    end
  end


  private

  def topic_params
    params.expect(
      topic: [ :name, :description, :estimated_hours, resources: [] ]
      )
  end

  def study_plan_id
    params[:study_plan_id] || params.expect(topic: :study_plan_id)[:study_plan_id]
  end

  def find_study_plan!
    @study_plan = current_user.study_plans.find(study_plan_id)
  end

  def find_topic!
    @topic = current_user.topics.find(params.expect(:id))
  end
end
