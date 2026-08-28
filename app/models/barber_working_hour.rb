class BarberWorkingHour < ApplicationRecord
  belongs_to :barber, class_name: "User"

  validates :weekday, inclusion: { in: 0..6 }, uniqueness: { scope: :barber_id }
  validates :opens_at, :closes_at, presence: true
  validate :closing_time_is_after_opening
  validate :barber_is_staff

  scope :for_weekday, ->(weekday) { where(weekday:) }

  def covers?(starts_at, ends_at)
    opens_at.strftime("%H:%M:%S") <= starts_at.strftime("%H:%M:%S") &&
      closes_at.strftime("%H:%M:%S") >= ends_at.strftime("%H:%M:%S")
  end

  private

  def closing_time_is_after_opening
    return if opens_at.blank? || closes_at.blank? || closes_at > opens_at

    errors.add(:closes_at, "must be after opening time")
  end

  def barber_is_staff
    return if barber.blank? || barber.barber?

    errors.add(:barber, "must have barber role")
  end
end
