require "test_helper"

class Admin::BarberWorkingHoursControllerTest < ActionDispatch::IntegrationTest
  test "admin manages a barber working period" do
    sign_in_as users(:two)

    assert_difference("BarberWorkingHour.count") do
      post admin_barber_working_hours_path, params: {
        barber_working_hour: {
          barber_id: users(:one).id,
          weekday: 1,
          opens_at: "09:00",
          closes_at: "18:00"
        }
      }
    end

    assert_redirected_to admin_barber_working_hours_path
    assert_equal "09:00", BarberWorkingHour.order(:id).last.opens_at.strftime("%H:%M")
  end

  test "barber cannot manage working periods" do
    sign_in_as users(:one)

    get admin_barber_working_hours_path

    assert_response :forbidden
  end
end
