module Admin
  class BarberWorkingHoursController < ApplicationController
    before_action :require_admin
    before_action :load_working_hour, only: %i[update destroy]

    def index
      load_form_data
      @barber_working_hours = BarberWorkingHour.includes(:barber).order(:barber_id, :weekday)
      @barber_working_hour = BarberWorkingHour.new
    end

    def create
      @barber_working_hour = BarberWorkingHour.new(barber_working_hour_params)
      @barber_working_hour.barber = User.where(role: :barber).find(barber_working_hour_params[:barber_id])

      if @barber_working_hour.save
        redirect_to admin_barber_working_hours_path, notice: "График мастера добавлен."
      else
        load_form_data
        @barber_working_hours = BarberWorkingHour.includes(:barber).order(:barber_id, :weekday)
        render :index, status: :unprocessable_content
      end
    end

    def update
      @barber_working_hour.update!(barber_working_hour_params.except(:barber_id))
      redirect_to admin_barber_working_hours_path, notice: "График мастера обновлён."
    end

    def destroy
      @barber_working_hour.destroy!
      redirect_to admin_barber_working_hours_path, notice: "График мастера удалён."
    end

    private

    def load_working_hour
      @barber_working_hour = BarberWorkingHour.find(params[:id])
    end

    def load_form_data
      @barbers = User.where(role: :barber).order(:email_address)
    end

    def barber_working_hour_params
      params.require(:barber_working_hour).permit(:barber_id, :weekday, :opens_at, :closes_at)
    end

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
