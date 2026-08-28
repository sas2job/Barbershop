require "test_helper"

class BookingScheduleTest < ActiveSupport::TestCase
  test "opens twelve hourly slots on weekdays" do
    monday = Date.new(2026, 8, 31)

    slots = BookingSchedule.slots_for(monday)

    assert_equal 12, slots.size
    assert_equal "08:00", slots.first.strftime("%H:%M")
    assert_equal "19:00", slots.last.strftime("%H:%M")
  end

  test "opens ten hourly slots on Sunday" do
    sunday = Date.new(2026, 8, 30)

    assert_equal 10, BookingSchedule.slots_for(sunday).size
  end
end
