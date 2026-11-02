class Settings::ProfilesController < ApplicationController
  def show
  end

  def update
    if current_user.update(profile_params)
      redirect_to settings_profile_path, notice: t("controllers.settings.profile_updated")
    else
      flash.now[:alert] = current_user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.expect(user: [ :name, :avatar, :time_zone ])
  end
end
