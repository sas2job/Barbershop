module Api
  module V1
    class BaseController < ApplicationController
      allow_unauthenticated_access
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

      private

      def render_not_found
        render json: { error: "Ресурс не найден" }, status: :not_found
      end
    end
  end
end
