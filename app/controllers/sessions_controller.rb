class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.authenticate_by(params.permit(:email_address, :password))

    if user&.active?
      start_new_session_for user
      redirect_to after_authentication_url
    elsif user && !user.active?
      redirect_to new_session_path, alert: t("sessions.account_inactive")
    else
      redirect_to new_session_path, alert: t("sessions.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other
  end
end
