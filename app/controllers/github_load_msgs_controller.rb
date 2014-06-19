class GithubLoadMsgsController < ApplicationController
  skip_before_filter :require_login
  before_action :set_github_load_msg, only: [:show, :edit, :update, :destroy]

  # GET /github_load_msgs
  # GET /github_load_msgs.json
  def index
    @github_load_msgs = GithubLoadMsg.all
  end

  # GET /github_load_msgs/1
  # GET /github_load_msgs/1.json
  def show
  end

  # GET /github_load_msgs/new
  def new
    @github_load_msg = GithubLoadMsg.new
  end

  # GET /github_load_msgs/1/edit
  def edit
  end

  # POST /github_load_msgs
  # POST /github_load_msgs.json
  def create
    @github_load_msg = GithubLoadMsg.new(github_load_msg_params)

    respond_to do |format|
      if @github_load_msg.save
        format.html { redirect_to @github_load_msg, notice: 'Github load msg was successfully created.' }
        format.json { render action: 'show', status: :created, location: @github_load_msg }
      else
        format.html { render action: 'new' }
        format.json { render json: @github_load_msg.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /github_load_msgs/1
  # PATCH/PUT /github_load_msgs/1.json
  def update
    respond_to do |format|
      if @github_load_msg.update(github_load_msg_params)
        format.html { redirect_to @github_load_msg, notice: 'Github load msg was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @github_load_msg.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /github_load_msgs/1
  # DELETE /github_load_msgs/1.json
  def destroy
    @github_load_msg.destroy
    respond_to do |format|
      format.html { redirect_to github_load_msgs_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_github_load_msg
      @github_load_msg = GithubLoadMsg.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def github_load_msg_params
      params.require(:github_load_msg).permit(:github_load_id, :msg, :log_level, :log_date)
    end
end
