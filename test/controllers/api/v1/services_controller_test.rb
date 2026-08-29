require "test_helper"

class Api::V1::ServicesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @women = Service.create!(name: "Женская стрижка", category: :women, duration_minutes: 60, price_from_cents: 60_000, price_to_cents: 80_000)
    @men = Service.create!(name: "Мужская стрижка", category: :men, duration_minutes: 45, price_from_cents: 55_000, price_to_cents: 55_000)
    @inactive = Service.create!(name: "Скрытая услуга", category: :men, duration_minutes: 30, price_from_cents: 1_000, price_to_cents: 1_000, active: false)
  end

  test "returns active services" do
    get api_v1_services_path, as: :json

    assert_response :success
    ids = JSON.parse(response.body).fetch("services").pluck("id")
    assert_includes ids, @women.id
    assert_includes ids, @men.id
    assert_not_includes ids, @inactive.id
  end

  test "filters services by category" do
    get api_v1_services_path, params: { category: "women" }, as: :json

    assert_response :success
    services = JSON.parse(response.body).fetch("services")
    assert_equal [ @women.id ], services.pluck("id")
  end

  test "rejects an unknown category" do
    get api_v1_services_path, params: { category: "children" }, as: :json

    assert_response :unprocessable_content
    assert_equal "category is invalid", JSON.parse(response.body).fetch("error")
  end
end
