require 'octokit_utils'
require 'constants'

class ConstantsController < ApplicationController

  def index
    begin
      render :json => JSON.pretty_generate(JSON.parse(File.read("config/graf/#{params[:constant]}.json")))
    rescue
      render :text => "Cannot find constant '#{params[:constant]}'"
    end
  end

  def clear
    Constants.clear_constants
    render :text => "Constants have been cleared'"
  end

end