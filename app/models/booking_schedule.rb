class BookingSchedule
  OPENING_HOURS = {
    1 => [ 8, 20 ],
    2 => [ 8, 20 ],
    3 => [ 8, 20 ],
    4 => [ 8, 20 ],
    5 => [ 8, 20 ],
    6 => [ 9, 20 ],
    0 => [ 9, 19 ]
  }.freeze

  def self.slots_for(date)
    opening_hour, closing_hour = OPENING_HOURS.fetch(date.wday)

    (opening_hour...closing_hour).map do |hour|
      Time.zone.local(date.year, date.month, date.day, hour)
    end
  end

  def self.open?(starts_at)
    starts_at == starts_at.beginning_of_hour && slots_for(starts_at.to_date).include?(starts_at)
  end
end
