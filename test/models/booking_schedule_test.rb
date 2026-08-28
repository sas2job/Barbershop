require "test_helper"

class BookingScheduleTest < ActiveSupport::TestCase
  setup do
    WorkingHour.delete_all
    BarberWorkingHour.delete_all
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

  test "capacity follows individual barber schedules" do
    second_barber = User.create!(
      email_address: "schedule-second-barber@example.com",
      password: "password",
      password_confirmation: "password",
      role: :barber
    )
    [users(:one), second_barber].each do |barber|
      BarberWorkingHour.create!(barber:, weekday: 1, opens_at: "09:00", closes_at: "18:00")
    end

    starts_at = Time.zone.local(2026, 8, 31, 10)
    TimeOff.create!(barber: users(:one), starts_at:, ends_at: starts_at + 1.hour)

    assert_equal 1, BookingSchedule.capacity_for(starts_at)
    assert_equal 0, BookingSchedule.capacity_for(Time.zone.local(2026, 8, 31, 18))
  end
end
