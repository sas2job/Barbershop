# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
services = [
  [ "Модельная стрижка (мытьё + сушка)", "women", 60, 60_000, 80_000 ],
  [ "Локоны (гофре, волна) + стайлинг", "women", 90, 140_000, 170_000 ],
  [ "Плетение кос", "women", 60, 65_000, 65_000 ],
  [ "Окрашивание в один тон", "women", 120, 240_000, 400_000 ],
  [ "Модельная стрижка (машинка + ножницы)", "men", 45, 55_000, 55_000 ],
  [ "Стрижка под машинку", "men", 30, 45_000, 45_000 ],
  [ "Оформление бороды", "men", 30, 35_000, 35_000 ],
  [ "Камуфлирование седины", "men", 45, 50_000, 50_000 ]
]

services.each do |name, category, duration, price_from, price_to|
  Service.find_or_create_by!(name:) do |service|
    service.category = category
    service.duration_minutes = duration
    service.price_from_cents = price_from
    service.price_to_cents = price_to
  end
end

working_hours = {
  0 => [ 9, 19 ],
  1 => [ 8, 20 ],
  2 => [ 8, 20 ],
  3 => [ 8, 20 ],
  4 => [ 8, 20 ],
  5 => [ 8, 20 ],
  6 => [ 9, 20 ]
}

working_hours.each do |weekday, (opens_at, closes_at)|
  working_hour = WorkingHour.find_or_initialize_by(weekday: weekday)
  working_hour.update!(opens_at: "#{opens_at}:00", closes_at: "#{closes_at}:00", capacity: 2)
end
