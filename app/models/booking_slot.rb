class BookingSlot < ApplicationRecord
  CAPACITY = 2

  has_many :bookings, dependent: :restrict_with_exception

  validates :starts_at, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }

  before_validation :set_default_capacity, on: :create

  private

  def set_default_capacity
    self.capacity ||= CAPACITY
  end
end
