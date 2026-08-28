class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :barber_working_hours, foreign_key: :barber_id, dependent: :destroy

  enum :role, { barber: "barber", admin: "admin" }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
