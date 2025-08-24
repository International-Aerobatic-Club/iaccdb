class Admin::ContestsController < ApplicationController
  before_action :authenticate

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.order(start: :desc)
  end

  # GET /contests/1/edit
  def edit
    load_contest
  end

  # PUT /contests/1
  def update
    load_contest

    if @contest.update_attributes(contest_params)
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    load_contest
    @contest.destroy

    redirect_to(admin_contests_url)
  end

  # GET /contests/1/recompute
  # GET /contests/
  def recompute
    load_contest
    # Delayed::Job.enqueue Jobs::ComputeFlightsJob.new(@contest)
    Jobs::ComputeFlightsJob.new(@contest).perform
    flash[:notice] = "#{@contest.year_name} queued for computation"
    redirect_to :action => 'index'
  end

  def contest_params
    params.require(:contest).permit(
      :name, :city, :state, :start, :chapter, :director, :region, :busy_start, :busy_end,
    )
  end

  def load_contest
    @contest = Contest.find(params[:id])
  end
end
