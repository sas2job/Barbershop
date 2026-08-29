module Api
  module V1
    class BookingsController < ApplicationController
      allow_unauthenticated_access

      def create
        service = Service.available_for_booking.find(params[:service_id])
        starts_at = parse_start_time
        validate_start_time!(starts_at)
        booking = Appointments::Book.call(service:, starts_at:, **booking_params.to_h.symbolize_keys)

        render json: {
          public_token: booking.public_token,
          status: booking.status,
          service_id: booking.service_id,
          starts_at: booking.booking_slot.starts_at.iso8601
        }, status: :created
      rescue Booking::SlotUnavailable
        render json: { error: "Это время уже занято" }, status: :unprocessable_content
      rescue ActiveRecord::RecordInvalid => error
        render json: { error: error.record.errors.full_messages.to_sentence }, status: :unprocessable_content
      end

      private

      def booking_params
        params.require(:booking).permit(:client_name, :phone_number)
      end

      def parse_start_time
        Time.zone.parse(params.dig(:booking, :starts_at).to_s)
      rescue ArgumentError, TypeError
        nil
      end

      def validate_start_time!(starts_at)
        return if starts_at && BookingSchedule.open?(starts_at) && starts_at.future?

        raise ActiveRecord::RecordInvalid, Booking.new
      end
    end
  end
end
