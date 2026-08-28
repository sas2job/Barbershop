require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "allows an admin to create a barber" do
    sign_in_as users(:two)

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          email_address: "new-barber@example.com",
          password: "password",
          password_confirmation: "password",
          role: "barber"
        }
      }
    end

    assert_redirected_to admin_dashboard_path
    assert_equal "barber", User.find_by(email_address: "new-barber@example.com").role
  end

  test "denies a barber" do
    sign_in_as users(:one)

    get new_admin_user_path

    assert_response :forbidden
  end

  test "rejects an unknown role" do
    sign_in_as users(:two)

    assert_no_difference("User.count") do
      post admin_users_path, params: {
        user: {
          email_address: "invalid-role@example.com",
          password: "password",
          password_confirmation: "password",
          role: "client"
        }
      }
    end

    assert_response :unprocessable_content
  end
end
