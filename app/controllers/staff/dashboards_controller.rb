module Staff
  class DashboardsController < ApplicationController
    before_action :require_staff

    def show
      render plain: "Staff dashboard"
    end

    private

    def require_staff
      return if Current.user&.barber? || Current.user&.admin?

      head :forbidden
    end
  end
end
