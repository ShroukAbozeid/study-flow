class StudySessionsController < ApplicationController
  def new
    @study_session = StudySession.new(topic_id: params[:topic_id])
  end

  def create
    @study_session = StudySession.new(study_session_params)
    if @study_session.save
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Study session created successfully." }
        format.html { redirect_to edit_study_plan_path(@study_session.topic.study_plan), notice: "Study session created successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @study_session = StudySession.find(params[:id])
  end

  def update
    @study_session = StudySession.find(params[:id])
    if @study_session.update(study_session_params)
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Study session updated successfully." }
        format.html { redirect_to edit_study_plan_path(@study_session.topic.study_plan), notice: "Study session updated successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def complete
    @study_session = StudySession.find(params[:id])
    if @study_session.update(finished_at: Time.current)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Study session completed successfully."
          render :update
        end
        format.html { redirect_to edit_study_plan_path(@study_session.topic.study_plan), notice: "Study session updated successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @study_session = StudySession.find(params[:id])
    @study_session.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Study session deleted successfully." }
      format.html { redirect_to edit_study_plan_path(@study_session.topic.study_plan), notice: "Study session deleted successfully." }
    end
  end

  private

  def study_session_params
    params.require(:study_session).permit(:title, :notes, :topic_id)
  end
end
