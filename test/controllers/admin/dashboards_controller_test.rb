require "test_helper"

class Admin::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "allows an admin" do
    sign_in_as users(:two)

    get admin_dashboard_path

    assert_response :success
  end

  test "denies a barber" do
    sign_in_as users(:one)

    get admin_dashboard_path

    assert_response :forbidden
  end

  test "shows bookings and barber assignment controls to an admin" do
    service = Service.create!(
      name: "Мужская стрижка",
      category: :men,
      duration_minutes: 45,
      price_from_cents: 55_000,
      price_to_cents: 55_000
    )
    Booking.reserve!(
      service: service,
      starts_at: BookingSchedule.slots_for(Date.current + 7).first,
      client_name: "Клиент",
      phone_number: "8-000-000-00-00"
    )
    sign_in_as users(:two)

    get admin_dashboard_path

    assert_response :success
    assert_select "h1", "Записи"
    assert_select "select[name='booking[barber_id]']"
  end
end
