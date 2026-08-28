class BookingsController < ApplicationController
  allow_unauthenticated_access

  before_action :load_service, only: %i[ new create ]
  before_action :load_booking, only: %i[ show cancel reschedule ]

  def new
    @date = requested_date
    @slots = available_slots
    @booking = Booking.new
  end

  def create
    @date = requested_date
    @slots = available_slots
    @booking = Booking.new(booking_params)
    starts_at = parse_start_time

    unless starts_at && BookingSchedule.open?(starts_at) && starts_at.future?
      @booking.errors.add(:base, "Выберите доступное время записи")
      return render :new, status: :unprocessable_content
    end

      booking = Appointments::Book.call(service: @service, starts_at:, **booking_params.to_h.symbolize_keys)
    redirect_to booking_path(booking.public_token), notice: "Запись подтверждена."
  rescue Booking::SlotUnavailable
    @booking.errors.add(:base, "Это время уже занято")
    render :new, status: :unprocessable_content
  rescue ActiveRecord::RecordInvalid => error
    @booking = error.record
    render :new, status: :unprocessable_content
  end

  def show
  end

  def cancel
    @booking.update!(status: :cancelled) if @booking.confirmed?
    redirect_to booking_path(@booking.public_token), notice: "Запись отменена."
  end

  def reschedule
    @service = @booking.service
    @date = requested_date
    @slots = available_slots(exclude_booking: @booking)

    if request.post?
      starts_at = parse_start_time
      unless starts_at && BookingSchedule.open?(starts_at) && starts_at.future? && starts_at != @booking.booking_slot.starts_at
        @booking.errors.add(:base, "Выберите другое доступное время записи")
        return render :reschedule, status: :unprocessable_content
      end

      new_booking = Booking.transaction do
        @booking.lock!
        raise Booking::SlotUnavailable unless @booking.confirmed?

        replacement = Booking.reserve!(
          service: @booking.service,
          starts_at: starts_at,
          client_name: @booking.client_name,
          phone_number: @booking.phone_number
        )
        @booking.update!(status: :annulled)
        replacement
      end

      redirect_to booking_path(new_booking.public_token), notice: "Запись перенесена."
    end
  rescue Booking::SlotUnavailable
    @booking.errors.add(:base, "Это время уже занято")
    render :reschedule, status: :unprocessable_content
  end

  private

  def load_service
    @service = Service.available_for_booking.find(params[:service_id] || booking_params[:service_id])
  end

  def load_booking
    @booking = Booking.find_by!(public_token: params[:public_token])
  end

  def booking_params
    params.require(:booking).permit(:client_name, :phone_number)
  end

  def requested_date
    Date.iso8601(params[:date].presence || params.dig(:booking, :date).presence || Date.current.iso8601)
  rescue ArgumentError
    Date.current
  end

  def parse_start_time
    Time.zone.parse(params.dig(:booking, :starts_at).to_s)
  rescue ArgumentError, TypeError
    nil
  end

  def available_slots(exclude_booking: nil)
    Availability::FindSlots.call(service: @service, date: @date, exclude_booking:)
  end
end
