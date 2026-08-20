require "application_system_test_case"

class ServicesTest < ApplicationSystemTestCase
  test "client sees the active service catalog" do
    Service.create!(name: "Женская стрижка", category: "women", duration_minutes: 60,
      price_from_cents: 60_000, price_to_cents: 80_000)
    Service.create!(name: "Архивная услуга", category: "men", duration_minutes: 30,
      price_from_cents: 10_000, price_to_cents: 10_000, active: false)

    visit root_path

    assert_text "Выберите услугу"
    assert_text "Женская стрижка"
    assert_text "600–800 ₽"
    assert_no_text "Архивная услуга"
  end
end
