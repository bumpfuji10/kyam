class AdminController < ApplicationController

  def new
  end

  def create
    admin = Admin.create(admin_params)
    if admin.save
      redirect_to "/"
    end
  end

  def login
  end

  private

  def admin_params
    params.permit(:name, :email, :password, :password_confirmation)
  end
end
