module Availability
  class FindSlots
    def self.call(service:, date:, exclude_booking: nil)
      new(service:, date:, exclude_booking:).call
    end

    def initialize(service:, date:, exclude_booking: nil)
      @service = service
      @date = date
      @exclude_booking = exclude_booking
    end

    def call
      BookingSchedule.slots_for(@date).select { |slot| available?(slot) }
    end

    private

    def available?(slot)
      return false unless slot.future?

      active_bookings = Booking.active.joins(:booking_slot).where(booking_slots: { starts_at: slot })
      active_bookings = active_bookings.where.not(id: @exclude_booking.id) if @exclude_booking
      active_bookings.count < BookingSchedule.capacity_for(slot)
    end
  end
end
