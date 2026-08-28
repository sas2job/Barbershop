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

  test "admin can edit booking details" do
    sign_in_as users(:two)
    replacement_time = BookingSchedule.slots_for(Date.current + 7).last

    get edit_admin_booking_path(@booking), params: { date: (Date.current + 7).iso8601 }
    assert_response :success

    patch admin_booking_path(@booking), params: {
      booking: {
        service_id: @booking.service_id,
        starts_at: replacement_time.iso8601,
        client_name: "Обновлённый клиент",
        phone_number: "8-000-000-00-00",
        barber_id: users(:one).id
      }
    }

    assert_redirected_to admin_dashboard_path
    assert_equal replacement_time, @booking.reload.booking_slot.starts_at
    assert_equal "Обновлённый клиент", @booking.client_name
    assert_equal users(:one), @booking.barber
  end

  test "admin edit keeps booking unchanged when new slot is full" do
    sign_in_as users(:two)
    replacement_time = BookingSchedule.slots_for(Date.current + 7).last
    2.times do
      Booking.reserve!(
        service: @booking.service,
        starts_at: replacement_time,
        client_name: "Клиент",
        phone_number: "8-000-000-00-00"
      )
    end

    patch admin_booking_path(@booking), params: {
      booking: { starts_at: replacement_time.iso8601 }
    }

    assert_response :unprocessable_content
    assert_equal @booking.booking_slot.starts_at, @booking.reload.booking_slot.starts_at
  end
end
