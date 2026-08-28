module Admin
  class TimeOffsController < ApplicationController
    before_action :require_admin
    before_action :load_time_off, only: :destroy

    def index
      @time_offs = TimeOff.includes(:barber).order(:starts_at)
      @barbers = User.where(role: :barber).order(:email_address)
      @time_off = TimeOff.new
    end

    def create
      @time_off = TimeOff.new(time_off_params)
      @time_off.barber = User.where(role: :barber).find(time_off_params[:barber_id])

      if @time_off.save
        redirect_to admin_time_offs_path, notice: "Отсутствие добавлено."
      else
        @time_offs = TimeOff.includes(:barber).order(:starts_at)
        @barbers = User.where(role: :barber).order(:email_address)
        render :index, status: :unprocessable_content
      end
    end

    def destroy
      @time_off.destroy!
      redirect_to admin_time_offs_path, notice: "Отсутствие удалено."
    end

    private

    def time_off_params
      params.require(:time_off).permit(:barber_id, :starts_at, :ends_at, :reason)
    end

    def load_time_off
      @time_off = TimeOff.find(params[:id])
    end

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
