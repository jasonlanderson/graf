class GrafUsersController < ApplicationController
  skip_before_filter :require_login

  # Signup screen
  def new
    # This page is to sign up a new user, if one exist then force the user to login
    unless can_signup?
      redirect_to login_url, :notice => "You must be logged in to create a new user if one already exists"
    end

    @graf_user = GrafUser.new
  end

  # Create a new user
  def create
    # This page is to sign up a new user, if one exist then force the user to login
    unless can_signup?
      redirect_to login_url, :notice => "You must be logged in to create a new user if one already exists"
    end

    @graf_user = GrafUser.new(user_params)
    if @graf_user.save
      redirect_to login_url, :notice => "Success...Please login with your new user"
    else
      render "new"
    end
  end

  def user_params
    params.require(:graf_user).permit(:email, :password_digest, :password, :password_confirmation)
  end

  def can_signup?
    GrafUser.all.size == 0 || current_user
  end
end
