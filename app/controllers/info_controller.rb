require 'octokit_utils'

class InfoController < ApplicationController
  skip_before_filter :require_login

  def index
        
  end
  
end