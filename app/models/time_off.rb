class TimeOff < ApplicationRecord
  belongs_to :barber, class_name: "User"

  validates :starts_at, :ends_at, presence: true
  validate :ends_after_start
  validate :barber_is_staff

  scope :overlapping, ->(range_start, range_end) {
    where("starts_at < ? AND ends_at > ?", range_end, range_start)
  }

  private

  def ends_after_start
    return if starts_at.blank? || ends_at.blank? || ends_at > starts_at

    errors.add(:ends_at, "must be after start time")
  end

  def barber_is_staff
    return if barber.blank? || barber.barber?

    errors.add(:barber, "must have barber role")
  end
end
