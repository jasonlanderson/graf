class SessionsController < ApplicationController
  skip_before_filter :require_login

  # Login screen
  def new
      # No users yet so redirect them to the signup page
      if GrafUser.all.size == 0
        redirect_to signup_url, :notice => "You must create your first user account"
      end
  end

  # Process login
  def create
    user = GrafUser.find_by_email(params[:email])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to load_url
    else
      @error = "Invalid email / password combination"
      render "new"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, :notice => "Logged out!"
  end
end
