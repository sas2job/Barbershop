require "test_helper"

class Api::V1::AvailabilityControllerTest < ActionDispatch::IntegrationTest
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

  test "returns available slots for an active service" do
    get api_v1_availability_path, params: { service_id: @service.id, date: @date.iso8601 }

    assert_response :success
    assert_equal "application/json", response.media_type
    body = JSON.parse(response.body)
    assert_equal @service.id, body.fetch("service_id")
    assert_equal @date.iso8601, body.fetch("date")
    assert_equal BookingSchedule.slots_for(@date).map(&:iso8601), body.fetch("slots")
  end

  test "does not return an inactive service" do
    @service.update!(active: false)

    get api_v1_availability_path, params: { service_id: @service.id, date: @date.iso8601 }

    assert_response :not_found
  end

  test "rejects an invalid date" do
    get api_v1_availability_path, params: { service_id: @service.id, date: "not-a-date" }

    assert_response :unprocessable_content
    assert_equal "date must be a valid ISO 8601 date", JSON.parse(response.body).fetch("error")
  end
end
