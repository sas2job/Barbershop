class WorkingHour < ApplicationRecord
  validates :weekday, inclusion: { in: 0..6 }, uniqueness: true
  validates :opens_at, :closes_at, presence: true
  validates :capacity, numericality: { only_integer: true, greater_than: 0 }
  validate :closing_time_is_after_opening

  private

  def closing_time_is_after_opening
    return if opens_at.blank? || closes_at.blank? || closes_at > opens_at

    errors.add(:closes_at, "must be after opening time")
  end
end
