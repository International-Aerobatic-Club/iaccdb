class Admin::ContestsController < ApplicationController
  before_filter :authenticate

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.includes(:manny_synch).order("start DESC")
    # admin/index.html.erb
  end

  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    redirect_to(admin_contests_url)
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    # admin/show.html.erb
  end

end
