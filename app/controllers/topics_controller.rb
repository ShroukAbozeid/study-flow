class TopicsController < ApplicationController
  def new
    @topic = Topic.new(study_plan_id: params[:study_plan_id])
  end

  def create
    @topic = Topic.new(topic_params)
    if @topic.save
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Topic created successfully." }
        format.html { redirect_to edit_study_plan_path(@topic.study_plan), notice: "Topic created successfully." }
      end
    else
      flash[:alert] = @topic.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @topic = Topic.find(params[:id])
  end

  def update
    @topic = Topic.find(params[:id])
    if @topic.update(topic_params)
       respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Topic updated successfully." }
        format.html { redirect_to edit_study_plan_path(@topic.study_plan), notice: "Topic updated successfully." }
      end
    else
      flash[:alert] = @topic.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @topic = Topic.find(params[:id])
    @topic.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Topic deleted successfully." }
      format.html { redirect_to edit_study_plan_path(@topic.study_plan), notice: "Topic deleted successfully." }
    end
  end


  private

  def topic_params
    params.require(:topic).permit(:name, :description, :estimated_hours, :study_plan_id)
  end
end
