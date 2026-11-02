class StudySessionsController < ApplicationController
  before_action :find_topic!, only: %i[new create]
  before_action :find_study_session!, only: %i[show edit update complete destroy]

  def show
  end
  def new
    @study_session = @topic.study_sessions.new
  end

  def edit
  end
  def create
    @study_session = @topic.study_sessions.new(study_session_params)
    if @study_session.save
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Study session created successfully." }
        format.html { redirect_to edit_study_plan_path(@study_session.study_plan), notice: "Study session created successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :new, status: :unprocessable_content
    end
  end


  def update
    if @study_session.update(study_session_params)
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Study session updated successfully." }
        format.html { redirect_to edit_study_plan_path(@study_session.study_plan), notice: "Study session updated successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def complete
    if @study_session.update(finished_at: Time.current)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Study session completed successfully."
          render :update
        end
        format.html { redirect_to edit_study_plan_path(@study_session.study_plan), notice: "Study session updated successfully." }
      end
    else
      flash[:alert] = @study_session.errors.full_messages.join(", ")
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @study_session.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:notice] = "Study session deleted successfully." }
      format.html { redirect_to edit_study_plan_path(@study_session.study_plan), notice: "Study session deleted successfully." }
    end
  end


  private

  def study_session_params
    params.expect(study_session: [ :title, :notes ])
  end

  def topic_id
    params[:topic_id] || params.expect(study_session: :topic_id)[:topic_id]
  end

  def find_topic!
    @topic = current_user.topics.find(topic_id)
  end

  def find_study_session!
    @study_session = current_user.study_sessions.find(params.expect(:id))
  end
end
