module Admin
  class BookingsController < ApplicationController
    before_action :require_admin
    before_action :load_booking

    def edit
      @services = Service.order(:name)
      @barbers = User.where(role: :barber).order(:email_address)
      @date = requested_date
      @slots = BookingSchedule.slots_for(@date)
    end

    def update
      attributes = booking_params
      service = Service.find(attributes[:service_id] || @booking.service_id)
      barber = User.where(role: :barber).find_by(id: attributes[:barber_id])
      starts_at = Time.zone.parse((attributes[:starts_at] || @booking.booking_slot.starts_at.iso8601).to_s)
      client_name = attributes[:client_name] || @booking.client_name
      phone_number = attributes[:phone_number] || @booking.phone_number

      unless starts_at && BookingSchedule.open?(starts_at) && starts_at.future?
        @booking.errors.add(:base, "Выберите доступное время записи")
        return render_edit
      end

      Booking.update_details!(booking: @booking, service: service, starts_at: starts_at,
        client_name: client_name, phone_number: phone_number, barber: barber)
      redirect_to admin_dashboard_path, notice: "Запись обновлена."
    rescue Booking::SlotUnavailable
      @booking.errors.add(:base, "Это время уже занято")
      render_edit
    rescue ActiveRecord::RecordInvalid => error
      @booking = error.record
      render_edit
    end

    private

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end

    def load_booking
      @booking = Booking.find(params[:id])
    end

    def booking_params
      params.require(:booking).permit(:service_id, :starts_at, :client_name, :phone_number, :barber_id)
    end

    def requested_date
      Date.iso8601(params[:date].presence || @booking.booking_slot.starts_at.to_date.iso8601)
    rescue ArgumentError
      @booking.booking_slot.starts_at.to_date
    end

    def render_edit
      @services = Service.order(:name)
      @barbers = User.where(role: :barber).order(:email_address)
      @date = requested_date
      @slots = BookingSchedule.slots_for(@date)
      render :edit, status: :unprocessable_content
    end
  end
end
