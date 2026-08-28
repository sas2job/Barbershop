require "test_helper"

class BookingScheduleTest < ActiveSupport::TestCase
  setup do
    WorkingHour.delete_all
    WorkingHour.create!(weekday: 1, opens_at: "08:00", closes_at: "20:00", capacity: 2)
    WorkingHour.create!(weekday: 0, opens_at: "09:00", closes_at: "19:00", capacity: 2)
  end

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
