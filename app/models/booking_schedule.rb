class BookingSchedule
  def self.slots_for(date)
    working_hour = WorkingHour.find_by!(weekday: date.wday)
    opening_hour = working_hour.opens_at.hour
    closing_hour = working_hour.closes_at.hour

    (opening_hour...closing_hour).map do |hour|
      Time.zone.local(date.year, date.month, date.day, hour)
    end
  end

  def self.open?(starts_at)
    starts_at == starts_at.beginning_of_hour && slots_for(starts_at.to_date).include?(starts_at)
  end
end
