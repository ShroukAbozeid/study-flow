class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("controllers.shared.rate_limited") }

  def new
  end

  def edit
  end
  def create
    if user = User.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t("controllers.passwords.reset_requested")
  end


  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t("controllers.passwords.reset")
    else
      redirect_to edit_password_path(params[:token]), alert: t("controllers.passwords.password_mismatch")
    end
  end

  private
    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token]) # rubocop:disable Rails/DynamicFindBy
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t("controllers.passwords.invalid_reset_link")
    end
end
