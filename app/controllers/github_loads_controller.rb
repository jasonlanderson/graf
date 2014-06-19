class GithubLoadsController < ApplicationController
  skip_before_filter :require_login
  before_action :set_github_load, only: [:show, :edit, :update, :destroy]

  # GET /github_loads
  # GET /github_loads.json
  def index
    @github_loads = GithubLoad.all
  end

  # GET /github_loads/1
  # GET /github_loads/1.json
  def show
  end

  # GET /github_loads/new
  def new
    @github_load = GithubLoad.new
  end

  # GET /github_loads/1/edit
  def edit
  end

  # POST /github_loads 
  # POST /github_loads.json
  def create
    @github_load = GithubLoad.new(github_load_params)

    respond_to do |format|
      if @github_load.save
        format.html { redirect_to @github_load, notice: 'Github load was successfully created.' }
        format.json { render action: 'show', status: :created, location: @github_load }
      else
        format.html { render action: 'new' }
        format.json { render json: @github_load.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /github_loads/1
  # PATCH/PUT /github_loads/1.json
  def update
    respond_to do |format|
      if @github_load.update(github_load_params)
        format.html { redirect_to @github_load, notice: 'Github load was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @github_load.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /github_loads/1
  # DELETE /github_loads/1.json
  def destroy
    @github_load.destroy
    respond_to do |format|
      format.html { redirect_to github_loads_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_github_load
      @github_load = GithubLoad.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def github_load_params
      params.require(:github_load).permit(:load_start_time, :load_complete_time, :initial_load)
    end
end
