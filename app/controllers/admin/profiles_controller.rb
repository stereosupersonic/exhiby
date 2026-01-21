module Admin
  class ProfilesController < BaseController
    def edit
      @user = current_user
    end

    def update
      @user = current_user

      unless @user.authenticate(params[:current_password])
        @user.errors.add(:current_password, :invalid)
        return render :edit, status: :unprocessable_entity
      end

      if @user.update(password_params)
        redirect_to admin_root_path, notice: t("admin.profile.messages.password_updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def password_params
      params.expect(user: %i[password password_confirmation])
    end
  end
end
