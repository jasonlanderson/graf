require 'octokit_utils'

class CacheController < ApplicationController

  def index
    @users = User.all
  end
  
end