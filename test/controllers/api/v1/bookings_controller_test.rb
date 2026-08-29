require "test_helper"

class Api::V1::BookingsControllerTest < ActionDispatch::IntegrationTest
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

  test "creates a confirmed booking and returns its public token" do
    assert_difference("Booking.count") do
      post api_v1_bookings_path, params: {
        service_id: @service.id,
        booking: {
          starts_at: @starts_at.iso8601,
          client_name: "Клиент",
          phone_number: "8-000-000-00-00"
        }
      }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "confirmed", body.fetch("status")
    assert_equal @service.id, body.fetch("service_id")
    assert_equal @starts_at.iso8601, body.fetch("starts_at")
    assert_match(/\A[A-Za-z0-9_-]{32,}\z/, body.fetch("public_token"))
    assert_nil body["id"]
  end

  test "returns an error when the slot is unavailable" do
    2.times do
      Booking.reserve!(
        service: @service,
        starts_at: @starts_at,
        client_name: "Клиент",
        phone_number: "8-000-000-00-00"
      )
    end

    assert_no_difference("Booking.count") do
      post api_v1_bookings_path, params: {
        service_id: @service.id,
        booking: {
          starts_at: @starts_at.iso8601,
          client_name: "Клиент",
          phone_number: "8-000-000-00-00"
        }
      }, as: :json
    end

    assert_response :unprocessable_content
    assert_equal "Это время уже занято", JSON.parse(response.body).fetch("error")
  end

  test "shows a booking by its public token without exposing client data" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    get api_v1_booking_path(booking.public_token), as: :json

    assert_response :success
    body = JSON.parse(response.body)
    assert_equal booking.public_token, body.fetch("public_token")
    assert_equal "confirmed", body.fetch("status")
    assert_nil body["client_name"]
    assert_nil body["phone_number"]
  end

  test "cancels a booking by its public token without deleting it" do
    booking = Booking.reserve!(
      service: @service,
      starts_at: @starts_at,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )

    assert_no_difference("Booking.count") do
      delete api_v1_booking_path(booking.public_token), as: :json
    end

    assert_response :success
    assert_equal "cancelled", JSON.parse(response.body).fetch("status")
    assert booking.reload.cancelled?
  end

  test "reschedules a booking atomically and returns a new public token" do
    booking = Booking.reserve!(service: @service, starts_at: @starts_at, client_name: "Клиент", phone_number: "8-000-000-00-00")
    replacement_time = BookingSchedule.slots_for(@date).last

    assert_difference("Booking.count") do
      patch api_v1_booking_path(booking.public_token), params: { booking: { starts_at: replacement_time.iso8601 } }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "confirmed", body.fetch("status")
    assert_not_equal booking.public_token, body.fetch("public_token")
    assert booking.reload.annulled?
  end

  test "keeps the original booking when the replacement slot is unavailable" do
    booking = Booking.reserve!(service: @service, starts_at: @starts_at, client_name: "Клиент", phone_number: "8-000-000-00-00")
    replacement_time = BookingSchedule.slots_for(@date).last
    2.times { Booking.reserve!(service: @service, starts_at: replacement_time, client_name: "Другой", phone_number: "8-000-000-00-00") }

    assert_no_difference("Booking.count") do
      patch api_v1_booking_path(booking.public_token), params: { booking: { starts_at: replacement_time.iso8601 } }, as: :json
    end

    assert_response :unprocessable_content
    assert booking.reload.confirmed?
  end
end
