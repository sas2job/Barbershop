require "test_helper"

class BookingConcurrencyTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  setup do
    @service = Service.create!(
      name: "Конкурентная проверка",
      category: :men,
      duration_minutes: 30,
      price_from_cents: 1_000,
      price_to_cents: 1_000
    )
    @date = Date.current + 7
    @starts_at = BookingSchedule.slots_for(@date).first
    @working_hour = WorkingHour.find_by!(weekday: @date.wday)
    @original_capacity = @working_hour.capacity
    @working_hour.update!(capacity: 1)
  end

  teardown do
    Booking.delete_all
    BookingSlot.delete_all
    Service.where(id: @service.id).delete_all
    @working_hour.update!(capacity: @original_capacity)
  end

  test "only one concurrent request reserves a single-capacity slot" do
    start_gate = Queue.new
    threads = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do
          start_gate.pop
          Booking.reserve!(
            service: @service,
            starts_at: @starts_at,
            client_name: "Клиент",
            phone_number: "8-000-000-00-00"
          )
          :reserved
        rescue Booking::SlotUnavailable
          :unavailable
        end
      end
    end
    2.times { start_gate << true }

    results = threads.map(&:value)

    assert_equal [ :reserved, :unavailable ], results.sort
    assert_equal 1, Booking.active.count
  end
end
