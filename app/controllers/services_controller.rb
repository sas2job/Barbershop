class ServicesController < ApplicationController
  allow_unauthenticated_access

  def index
    @services_by_category = Service.available_for_booking.order(:name).group_by(&:category)
  end
end
