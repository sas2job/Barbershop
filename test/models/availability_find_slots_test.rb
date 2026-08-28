require "test_helper"

class AvailabilityFindSlotsTest < ActiveSupport::TestCase
  setup do
    @service = Service.create!(
      name: "Мужская стрижка",
      category: :men,
      duration_minutes: 45,
      price_from_cents: 55_000,
      price_to_cents: 55_000
    )
    @date = Date.current + 7
  end

  test "returns hourly slots with capacity" do
    slots = Availability::FindSlots.call(service: @service, date: @date)

    assert_equal BookingSchedule.slots_for(@date), slots
  end

  test "removes a slot when both barbers are unavailable" do
    slot = BookingSchedule.slots_for(@date).first
    second_barber = User.create!(
      email_address: "second-barber@example.com",
      password: "password",
      password_confirmation: "password",
      role: :barber
    )
    [ users(:one), second_barber ].each do |barber|
      TimeOff.create!(barber:, starts_at: slot, ends_at: slot + 1.hour)
    end

    slots = Availability::FindSlots.call(service: @service, date: @date)

    assert_not_includes slots, slot
  end
end
