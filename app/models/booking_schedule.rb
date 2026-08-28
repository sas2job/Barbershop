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

  def self.capacity_for(starts_at)
    weekday_working_hours = BarberWorkingHour.for_weekday(starts_at.to_date.wday)
    scheduled_barber_ids = weekday_working_hours.select do |working_hour|
      working_hour.covers?(starts_at, starts_at + 1.hour)
    end.map(&:barber_id).uniq
    if scheduled_barber_ids.empty? && weekday_working_hours.none?
      working_capacity = WorkingHour.find_by!(weekday: starts_at.to_date.wday).capacity
      unavailable_barbers = TimeOff.overlapping(starts_at, starts_at + 1.hour).distinct.count(:barber_id)
      return [ working_capacity - unavailable_barbers, 0 ].max
    end
    unavailable_barber_ids = TimeOff.overlapping(starts_at, starts_at + 1.hour)
      .where(barber_id: scheduled_barber_ids)
      .distinct
      .pluck(:barber_id)
    [ scheduled_barber_ids.length - unavailable_barber_ids.length, 0 ].max
  end
end
