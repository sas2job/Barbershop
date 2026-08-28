class Booking < ApplicationRecord
  class SlotUnavailable < StandardError; end

  belongs_to :service
  belongs_to :booking_slot
  belongs_to :barber, class_name: "User", optional: true

  enum :status, { confirmed: "confirmed", cancelled: "cancelled", annulled: "annulled" }, validate: true

  scope :active, -> { where(status: statuses[:confirmed]) }

  validates :client_name, presence: true
  validates :phone_number, presence: true, format: { with: /\A8-\d{3}-\d{3}-\d{2}-\d{2}\z/ }
  validates :public_token, presence: true, uniqueness: true

  def self.reserve!(service:, starts_at:, client_name:, phone_number:)
    transaction(requires_new: true) do
      slot = BookingSlot.create_or_find_by!(starts_at: starts_at) do |new_slot|
        new_slot.capacity = BookingSchedule.capacity_for(starts_at)
      end

      slot.with_lock do
        raise SlotUnavailable if slot.bookings.active.count >= slot.capacity

        create!(
          service: service,
          booking_slot: slot,
          client_name: client_name,
          phone_number: phone_number,
          public_token: SecureRandom.urlsafe_base64(32),
          status: :confirmed
        )
      end
    end
  end

  before_validation :generate_public_token, on: :create

  private

  def generate_public_token
    self.public_token ||= SecureRandom.urlsafe_base64(32)
  end
end
