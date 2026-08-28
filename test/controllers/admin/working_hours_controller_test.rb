require "test_helper"

class Admin::WorkingHoursControllerTest < ActionDispatch::IntegrationTest
  test "admin can view and update working hours" do
    sign_in_as users(:two)
    working_hour = working_hours(:monday)

    get admin_working_hours_path
    assert_response :success
    assert_select "h1", "Рабочие часы"

    patch admin_working_hour_path(working_hour), params: {
      working_hour: { opens_at: "09:00", closes_at: "18:00", capacity: 2 }
    }

    assert_redirected_to admin_working_hours_path
    assert_equal "09:00", working_hour.reload.opens_at.strftime("%H:%M")
  end

  test "barber cannot update working hours" do
    sign_in_as users(:one)

    patch admin_working_hour_path(working_hours(:monday)), params: {
      working_hour: { opens_at: "09:00", closes_at: "18:00", capacity: 2 }
    }

    assert_response :forbidden
  end
end
