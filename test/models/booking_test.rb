require "test_helper"

class BookingTest < ActiveSupport::TestCase
  setup do
    @service = Service.create!(
      name: "Мужская стрижка",
      category: :men,
      duration_minutes: 45,
      price_from_cents: 55_000,
      price_to_cents: 55_000
    )
    @starts_at = BookingSchedule.slots_for(Date.current + 7).first
  end

  test "reserves a confirmed booking with an unpredictable public token" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    assert booking.confirmed?
    assert booking.public_token.length >= 32
    assert_equal @starts_at, booking.booking_slot.starts_at
  end

  test "allows two bookings in a slot and rejects the third" do
    2.times do
      Booking.reserve!(
        service: @service,
        starts_at: @starts_at,
        client_name: "Клиент",
        phone_number: "8-000-000-00-00"
      )
    end

    assert_raises Booking::SlotUnavailable do
      Booking.reserve!(
        service: @service,
        starts_at: @starts_at,
        client_name: "Клиент",
        phone_number: "8-000-000-00-00"
      )
    end
    assert_equal 2, Booking.active.count
  end

  test "requires the documented phone format" do
    booking = Booking.new(phone_number: "80000000000")

    assert_not booking.valid?
    assert_includes booking.errors[:phone_number], "is invalid"
  end
end
