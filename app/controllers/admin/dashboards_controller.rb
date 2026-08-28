module Admin
  class DashboardsController < ApplicationController
    before_action :require_admin

    def show
      @bookings = Booking.includes(:service, :booking_slot, :barber).order("booking_slots.starts_at")
      @barbers = User.where(role: :barber).order(:email_address)
    end

    private

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end
  end
end
