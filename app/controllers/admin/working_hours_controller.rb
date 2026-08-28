module Admin
  class WorkingHoursController < ApplicationController
    before_action :require_admin

    def index
      @working_hours = WorkingHour.order(:weekday)
    end

    def update
      working_hour = WorkingHour.find(params[:id])
      working_hour.update!(working_hour_params)
      redirect_to admin_working_hours_path, notice: "Расписание обновлено."
    end

    private

    def working_hour_params
      params.require(:working_hour).permit(:opens_at, :closes_at, :capacity)
    end

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
