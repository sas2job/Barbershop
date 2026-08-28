require "test_helper"

class TimeOffTest < ActiveSupport::TestCase
  test "accepts an absence for a barber" do
    time_off = TimeOff.new(
      barber: users(:one),
      starts_at: Time.zone.parse("2026-09-01 10:00"),
      ends_at: Time.zone.parse("2026-09-01 12:00")
    )

    assert time_off.valid?
  end

  test "rejects an absence for an admin" do
    time_off = TimeOff.new(
      barber: users(:two),
      starts_at: Time.zone.parse("2026-09-01 10:00"),
      ends_at: Time.zone.parse("2026-09-01 12:00")
    )

    assert_not time_off.valid?
  end
end
