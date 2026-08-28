module Admin
  class DashboardsController < ApplicationController
    before_action :require_admin

    def show
      render plain: "Admin dashboard"
    end

    private

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
