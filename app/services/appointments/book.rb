module Appointments
  class Book
    def self.call(service:, starts_at:, client_name:, phone_number:)
      Booking.reserve!(
        service:,
        starts_at:,
        client_name:,
        phone_number:
      )
    end
  end
end
