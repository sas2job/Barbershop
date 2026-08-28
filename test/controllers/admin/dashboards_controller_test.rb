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
end
