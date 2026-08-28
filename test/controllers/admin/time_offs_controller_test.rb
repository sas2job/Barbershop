require "test_helper"

class Admin::TimeOffsControllerTest < ActionDispatch::IntegrationTest
  test "admin can create and delete a barber absence" do
    sign_in_as users(:two)
    starts_at = Time.zone.parse("2026-09-01 10:00")

    assert_difference("TimeOff.count") do
      post admin_time_offs_path, params: {
        time_off: {
          barber_id: users(:one).id,
          starts_at: starts_at.iso8601,
          ends_at: (starts_at + 2.hours).iso8601,
          reason: "Отпуск"
        }
      }
    end

    time_off = TimeOff.order(:id).last
    assert_redirected_to admin_time_offs_path

    assert_difference("TimeOff.count", -1) do
      delete admin_time_off_path(time_off)
    end
    assert_redirected_to admin_time_offs_path
  end

  test "barber cannot create an absence" do
    sign_in_as users(:one)

    post admin_time_offs_path, params: {
      time_off: {
        barber_id: users(:one).id,
        starts_at: "2026-09-01T10:00:00+03:00",
        ends_at: "2026-09-01T12:00:00+03:00"
      }
    }

    assert_response :forbidden
  end
end
