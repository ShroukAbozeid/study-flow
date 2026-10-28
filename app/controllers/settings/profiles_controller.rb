class Settings::ProfilesController < ApplicationController
  def show
  end

  def update
    if Current.user.update(profile_params)
      redirect_to settings_profile_path, notice: "Profile updated successfully."
    else
      flash.now[:alert] = Current.user.errors.full_messages.join(", ")
      render :show, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :avatar, :time_zone)
  end
end
