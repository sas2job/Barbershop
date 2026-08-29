module Api
  module V1
    class AvailabilityController < ApplicationController
      allow_unauthenticated_access

      def show
        service = Service.available_for_booking.find(params[:service_id])
        date = Date.iso8601(params[:date])
        slots = Availability::FindSlots.call(service:, date:)

        render json: {
          service_id: service.id,
          date: date.iso8601,
          slots: slots.map(&:iso8601)
        }
      rescue ArgumentError
        render json: { error: "date must be a valid ISO 8601 date" }, status: :unprocessable_content
      end
    end
  end
end
