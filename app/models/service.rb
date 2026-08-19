class Service < ApplicationRecord
  enum :category, {
    women: "women",
    men: "men"
  }, validate: true

  scope :available_for_booking, -> { where(active: true) }
  scope :in_category, ->(category) { where(category: category) }

  validates :name, presence: true
  validates :duration_minutes,
    numericality: { only_integer: true, greater_than: 0 }
  validates :price_from_cents,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :price_to_cents,
    numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :price_range_is_ordered

  private

  def price_range_is_ordered
    return if price_from_cents.blank? || price_to_cents.blank?
    return if price_to_cents >= price_from_cents

    errors.add(:price_to_cents, "must be greater than or equal to the minimum price")
  end
end
