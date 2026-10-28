class Settings::StudyPreferencesController < ApplicationController
  def show
  end

  def update
    if Current.user.update(study_preferences_params)
      redirect_to settings_study_preferences_path, notice: "Settings saved."
    else
      flash.now[:alert] = Current.user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def study_preferences_params
  params.require(:user).permit(
    study_preferences: [
      :week_start_day,
      {
        daily_reminder_notification: [ :enabled, :time ],
        weekly_progress_report: [ :enabled, :day, :time ]
      }
    ]
  )
end
end
