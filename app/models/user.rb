class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { barber: "barber", admin: "admin" }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
