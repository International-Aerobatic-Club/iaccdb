class Admin::ContestsController < ApplicationController
  before_filter :authenticate

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.includes(:manny_synch).order("start DESC")
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # PUT /contests/1
  def update
    @contest = Contest.find(params[:id])

    if @contest.update_attributes(params[:contest])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
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
