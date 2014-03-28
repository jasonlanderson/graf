require 'octokit_utils'

class ConstantsController < ApplicationController

  def index
    begin
      render :json => JSON.pretty_generate(JSON.parse(File.read("config/graf/#{params[:constant]}.json")))
    rescue
      render :text => "Cannot find constant '#{params[:constant]}'"
    end
  end
  
end