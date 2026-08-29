module Api
  module V1
    class ServicesController < BaseController
      def index
        category = params[:category].presence
        if category && !Service.categories.key?(category)
          return render json: { error: "category is invalid" }, status: :unprocessable_content
        end

        services = Service.available_for_booking
        services = services.in_category(category) if category

        render json: { services: services.map { |service| service_json(service) } }
      end

      private

      def service_json(service)
        {
          id: service.id,
          name: service.name,
          category: service.category,
          duration_minutes: service.duration_minutes,
          price_from_cents: service.price_from_cents,
          price_to_cents: service.price_to_cents
        }
      end
    end
  end
end
