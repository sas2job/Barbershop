require "test_helper"

class ServiceTest < ActiveSupport::TestCase
  def valid_attributes
    {
      name: "Модельная стрижка",
      category: "women",
      duration_minutes: 60,
      price_from_cents: 60_000,
      price_to_cents: 80_000,
      active: true
    }
  end

  test "accepts a service with a price range" do
    assert Service.new(valid_attributes).valid?
  end

  test "accepts a service with a fixed price" do
    service = Service.new(valid_attributes.merge(price_to_cents: 60_000))

    assert service.valid?
  end

  test "requires a name and a supported category" do
    assert_not Service.new(valid_attributes.merge(name: nil)).valid?
    assert_not Service.new(valid_attributes.merge(category: nil)).valid?
    assert_not Service.new(valid_attributes.merge(category: "other")).valid?
  end

  test "requires a positive duration" do
    assert_not Service.new(valid_attributes.merge(duration_minutes: 0)).valid?
    assert_not Service.new(valid_attributes.merge(duration_minutes: -1)).valid?
  end

  test "requires non-negative prices" do
    assert_not Service.new(valid_attributes.merge(price_from_cents: -1)).valid?
    assert_not Service.new(valid_attributes.merge(price_to_cents: -1)).valid?
  end

  test "requires the maximum price to be at least the minimum price" do
    service = Service.new(valid_attributes.merge(price_to_cents: 59_900))

    assert_not service.valid?
  end

  test "filters services by category" do
    women = Service.create!(valid_attributes)
    men = Service.create!(
      valid_attributes.merge(
        name: "Стрижка под машинку",
        category: "men",
        duration_minutes: 30,
        price_from_cents: 45_000,
        price_to_cents: 45_000
      )
    )

    assert_includes Service.in_category("women"), women
    assert_not_includes Service.in_category("women"), men
  end

  test "only active services are available for booking" do
    active = Service.create!(valid_attributes)
    inactive = Service.create!(
      valid_attributes.merge(name: "Архивная услуга", active: false)
    )

    assert_includes Service.available_for_booking, active
    assert_not_includes Service.available_for_booking, inactive
  end
end
