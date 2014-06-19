class GrafUsersController < ApplicationController
  skip_before_filter :require_login
  def new
    @graf_user = GrafUser.new
  end

  def create
    @graf_user = GrafUser.new(user_params)
    if @graf_user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def user_params
    params.require(:graf_user).permit(:email, :password_digest, :password, :password_confirmation)
  end
end
