class ApplicationController < ActionController::Base
  #https://github.com/rails/rails/issues/3041
  skip_before_filter :verify_authenticity_token
  # protect_from_forgery
  # TODO: Need to add back in
  #force_ssl
  before_filter :require_login

  private

  def require_login
    unless current_user
      redirect_to login_url
    end
  end

  def current_user
    @current_user ||= GrafUser.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
