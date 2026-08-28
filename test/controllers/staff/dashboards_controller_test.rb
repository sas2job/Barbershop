require "test_helper"

class Staff::DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "allows a signed-in barber" do
    sign_in_as users(:one)

    get staff_dashboard_path

    assert_response :success
  end

  test "requires authentication" do
    get staff_dashboard_path

    assert_redirected_to new_session_path
  end
end
