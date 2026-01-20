module Admin
  class UsersController < BaseController
    before_action :set_user, only: %i[edit update deactivate activate]

    def index
      @users = User.order(active: :desc, created_at: :desc)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_users_path, notice: t("admin.users.messages.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def deactivate
      if @user == current_user
        redirect_to admin_users_path, alert: t("admin.users.messages.cannot_deactivate_self")
      else
        @user.deactivate!
        redirect_to admin_users_path, notice: t("admin.users.messages.deactivated")
      end
    end

    def activate
      @user.activate!
      redirect_to admin_users_path, notice: t("admin.users.messages.activated")
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.expect(user: %i[email_address role])
    end
  end
end
