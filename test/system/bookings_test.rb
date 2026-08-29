require "application_system_test_case"

class BookingsTest < ApplicationSystemTestCase
  setup do
    @service = Service.create!(
      name: "Мужская стрижка",
      category: :men,
      duration_minutes: 45,
      price_from_cents: 55_000,
      price_to_cents: 55_000
    )
    @date = Date.current + 7
    @next_date = @date + 1
  end

  test "refreshes available slots after changing the date" do
    visit new_booking_path(service_id: @service.id, date: @date.iso8601)

    date_field = find("[data-booking-date]")
    execute_script(
      "arguments[0].value = arguments[1]; arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
      date_field,
      @next_date.iso8601
    )

    expected_slot = BookingSchedule.slots_for(@next_date).first
    assert_selector "select[data-booking-slots] option[value='#{expected_slot.iso8601}']", wait: 5
    assert_equal @next_date.iso8601, find("[data-booking-date-value]", visible: false).value
  end

  test "refreshes rescheduling slots after changing the date" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: BookingSchedule.slots_for(@date).first,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    visit reschedule_booking_path(booking.public_token, date: @date.iso8601)

    date_field = find("[data-booking-date]")
    execute_script(
      "arguments[0].value = arguments[1]; arguments[0].dispatchEvent(new Event('change', { bubbles: true }));",
      date_field,
      @next_date.iso8601
    )

    expected_slot = BookingSchedule.slots_for(@next_date).first
    assert_selector "select[data-booking-slots] option[value='#{expected_slot.iso8601}']", wait: 5
    assert_equal @next_date.iso8601, find("[data-booking-date-value]", visible: false).value
  end
end
