require 'octokit_utils'

class CacheController < ApplicationController
  skip_before_filter :require_login

  def index
    @users = User.all
  end
  
end