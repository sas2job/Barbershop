class UpdateCatalogFromPriceList < ActiveRecord::Migration[8.1]
  def up
    update_service("Стрижка под машинку", "Стрижка под машинку (2 и более насадки)", "men", 30, 45_000)
    update_service("Камуфлирование седины", "Камуфлирование седины «Estel Alpha Homme»", "men", 30, 60_000)

    add_service("Работа с применением шейвера", "men", 30, 5_000)
    add_service("Стрижка под одну насадку", "men", 30, 35_000)
    add_service("Стрижка наголо", "men", 15, 30_000)
    add_service("Модельная стрижка с элементами креатива (машинка + ножницы)", "men", 45, 60_000)
  end

  def down
    Service.where(name: [
      "Работа с применением шейвера",
      "Стрижка под одну насадку",
      "Стрижка наголо",
      "Модельная стрижка с элементами креатива (машинка + ножницы)"
    ]).delete_all
    update_service("Стрижка под машинку (2 и более насадки)", "Стрижка под машинку", "men", 30, 45_000)
    update_service("Камуфлирование седины «Estel Alpha Homme»", "Камуфлирование седины", "men", 45, 50_000)
  end

  private

  def update_service(old_name, name, category, duration, price)
    service = Service.find_by(name: old_name) || Service.find_or_initialize_by(name: name)
    service.update!(name: name, category: category, duration_minutes: duration, price_from_cents: price, price_to_cents: price)
  end

  def add_service(name, category, duration, price)
    Service.find_or_create_by!(name: name) do |service|
      service.category = category
      service.duration_minutes = duration
      service.price_from_cents = price
      service.price_to_cents = price
    end
  end
end
