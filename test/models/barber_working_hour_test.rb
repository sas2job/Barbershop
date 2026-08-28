require "test_helper"

class BarberWorkingHourTest < ActiveSupport::TestCase
  setup do
    @barber = users(:one)
  end

  test "accepts a working period for a barber" do
    working_hour = BarberWorkingHour.new(
      barber: @barber,
      weekday: 1,
      opens_at: "09:00",
      closes_at: "18:00"
    )

    assert working_hour.valid?
    assert working_hour.covers?(Time.zone.local(2026, 8, 31, 10), Time.zone.local(2026, 8, 31, 11))
    assert_not working_hour.covers?(Time.zone.local(2026, 8, 31, 8), Time.zone.local(2026, 8, 31, 9))
  end

  test "rejects a non-barber" do
    working_hour = BarberWorkingHour.new(
      barber: users(:two),
      weekday: 1,
      opens_at: "09:00",
      closes_at: "18:00"
    )

    assert_not working_hour.valid?
    assert_includes working_hour.errors[:barber], "must have barber role"
  end

  test "allows only one period per barber and weekday" do
    BarberWorkingHour.create!(barber: @barber, weekday: 1, opens_at: "09:00", closes_at: "18:00")
    duplicate = BarberWorkingHour.new(barber: @barber, weekday: 1, opens_at: "10:00", closes_at: "19:00")

    assert_not duplicate.valid?
    assert_includes duplicate.errors[:weekday], "has already been taken"
  end
end
