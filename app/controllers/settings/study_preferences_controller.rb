class Settings::StudyPreferencesController < ApplicationController
  def show
  end

  def update
    preferences = current_user.study_preferences.deep_merge(study_preferences_params[:study_preferences].to_h)

    if current_user.update(study_preferences: preferences)
      redirect_to settings_study_preferences_path, notice: t("controllers.settings.study_preferences_saved")
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
