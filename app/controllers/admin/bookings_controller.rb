module Admin
  class BookingsController < ApplicationController
    before_action :require_admin

    def update
      booking = Booking.find(params[:id])
      barber = User.where(role: :barber).find(params.require(:booking).permit(:barber_id)[:barber_id])
      booking.update!(barber: barber)
      redirect_to admin_dashboard_path, notice: "Мастер назначен."
    end

    private

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
