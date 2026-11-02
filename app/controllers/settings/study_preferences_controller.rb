class Settings::StudyPreferencesController < ApplicationController
  def show
  end

  def update
    if current_user.update(study_preferences_params)
      redirect_to settings_study_preferences_path, notice: "Settings saved."
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_content
    end
  end

  private

  def study_preferences_params
    params.expect(
      user: [ study_preferences: [
        :week_start_day,
        {
          daily_reminder_notification: [ :enabled, :time ],
          weekly_progress_report: [ :enabled, :day, :time ]
        }
      ] ]
    )
  end
end
