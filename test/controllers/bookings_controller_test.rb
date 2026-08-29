require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @service = Service.create!(
      name: "Мужская стрижка",
      category: :men,
      duration_minutes: 45,
      price_from_cents: 55_000,
      price_to_cents: 55_000
    )
    @date = Date.current + 7
    @starts_at = BookingSchedule.slots_for(@date).first
  end

  test "shows available booking slots for an active service" do
    get new_booking_path, params: { service_id: @service.id, date: @date.iso8601 }

    assert_response :success
    assert_select "h1", "Запись на услугу"
    assert_select "option", text: @starts_at.strftime("%H:%M")
  end

  test "creates a confirmed booking and redirects to its token page" do
    assert_difference("Booking.count") do
      post bookings_path, params: {
        service_id: @service.id,
        date: @date.iso8601,
        booking: {
          starts_at: @starts_at.iso8601,
          client_name: "Клиент",
          phone_number: "8-000-000-00-00"
        }
      }
    end

    booking = Booking.order(:id).last
    assert_redirected_to booking_path(booking.public_token)
    follow_redirect!
    assert_response :success
    assert_select "h1", "Запись подтверждена"
  end

  test "does not expose a booking through its database id" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    get "/bookings/#{booking.id}"

    assert_response :not_found
  end

  test "cancels a booking without deleting its history" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    assert_no_difference("Booking.count") do
      post cancel_booking_path(booking.public_token)
    end

    assert_redirected_to booking_path(booking.public_token)
    assert booking.reload.cancelled?
  end

  test "reschedules atomically and annuls the original booking" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )
    replacement_time = BookingSchedule.slots_for(@date).last

    assert_difference("Booking.count") do
      post reschedule_booking_path(booking.public_token), params: {
        date: @date.iso8601,
        booking: { starts_at: replacement_time.iso8601 }
      }
    end

    assert_redirected_to booking_path(Booking.order(:id).last.public_token)
    assert booking.reload.annulled?
    assert Booking.order(:id).last.confirmed?
  end

  test "keeps the original booking when replacement slot is full" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )
    replacement_time = BookingSchedule.slots_for(@date).last
    2.times do
      Booking.reserve!(
        service: @service,
        starts_at: replacement_time,
        client_name: "Клиент",
        phone_number: "8-000-000-00-00"
      )
    end

    assert_no_difference("Booking.count") do
      post reschedule_booking_path(booking.public_token), params: {
        date: @date.iso8601,
        booking: { starts_at: replacement_time.iso8601 }
      }
    end

    assert_response :unprocessable_content
    assert booking.reload.confirmed?
  end
end
