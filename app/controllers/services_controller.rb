class ServicesController < ApplicationController
  allow_unauthenticated_access

  def index
    @category = params[:category].presence
    @category = nil unless Service.categories.key?(@category)
    services = Service.available_for_booking
    services = services.in_category(@category) if @category
    @services_by_category = services.order(:name).group_by(&:category)
  end
end
