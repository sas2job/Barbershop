module Appointments
  class Reschedule
    def self.call(booking:, starts_at:)
      Booking.transaction do
        booking.lock!
        raise Booking::SlotUnavailable unless booking.confirmed?

        replacement = Booking.reserve!(
          service: booking.service,
          starts_at:,
          client_name: booking.client_name,
          phone_number: booking.phone_number
        )
        booking.update!(status: :annulled)
        replacement
      end
    end
  end
end
