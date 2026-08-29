require "test_helper"

class ServicesControllerTest < ActionDispatch::IntegrationTest
  test "shows active services grouped by category" do
    Service.create!(name: "Женская стрижка", category: "women", duration_minutes: 60,
      price_from_cents: 60_000, price_to_cents: 80_000)
    Service.create!(name: "Мужская стрижка", category: "men", duration_minutes: 45,
      price_from_cents: 55_000, price_to_cents: 55_000)
    Service.create!(name: "Архивная услуга", category: "men", duration_minutes: 30,
      price_from_cents: 10_000, price_to_cents: 10_000, active: false)

    get root_url

    assert_response :success
    assert_select "h1", "Выберите услугу"
    assert_select "h2", "Женский зал"
    assert_select "h2", "Мужской зал"
    assert_select ".service-card", count: 2
    assert_select ".service-card", text: /600–800 ₽/
    assert_select ".service-card", text: /550 ₽/
    assert_not_includes response.body, "Архивная услуга"
  end
end

class ServicesFilterTest < ActionDispatch::IntegrationTest
  test "filters active services by category" do
    women = Service.create!(name: "Женская", category: :women, duration_minutes: 60, price_from_cents: 1_000, price_to_cents: 1_000)
    Service.create!(name: "Мужская", category: :men, duration_minutes: 30, price_from_cents: 1_000, price_to_cents: 1_000)

    get root_path, params: { category: "women" }

    assert_response :success
    assert_select ".service-card h3", text: women.name
    assert_select ".service-card h3", text: "Мужская", count: 0
  end
end
