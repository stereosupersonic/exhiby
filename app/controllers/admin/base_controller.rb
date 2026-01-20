module Admin
  class BaseController < ApplicationController
    layout "admin"
    before_action :authorize_admin_access

    private

    def authorize_admin_access
      authorize! :manage, :admin_area
    end
  end
end
