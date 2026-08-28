module Admin
  class UsersController < ApplicationController
    before_action :require_admin

    def new
      @user = User.new(role: :barber)
    end

    def create
      attributes = user_params
      unless User.roles.key?(attributes[:role])
        @user = User.new(attributes.except(:role))
        @user.errors.add(:role, "is invalid")
        return render :new, status: :unprocessable_content
      end

      @user = User.new(attributes)
      if @user.save
        redirect_to admin_dashboard_path, notice: "Staff user created."
      else
        render :new, status: :unprocessable_content
      end
    end

    private

    def require_admin
      return if Current.user&.admin?

      head :forbidden
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation, :role)
    end
  end
end
