require "test_helper"

class Admin::BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @booking = Booking.reserve!(
      service: Service.create!(
        name: "Мужская стрижка",
        category: :men,
        duration_minutes: 45,
        price_from_cents: 55_000,
        price_to_cents: 55_000
      ),
      starts_at: BookingSchedule.slots_for(Date.current + 7).first,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )
  end

  test "admin assigns a barber" do
    sign_in_as users(:two)

    patch admin_booking_path(@booking), params: { booking: { barber_id: users(:one).id } }

    assert_redirected_to admin_dashboard_path
    assert_equal users(:one), @booking.reload.barber
  end

  test "barber cannot assign a barber" do
    sign_in_as users(:one)

    patch admin_booking_path(@booking), params: { booking: { barber_id: users(:one).id } }

    assert_response :forbidden
    assert_nil @booking.reload.barber
  end
end
