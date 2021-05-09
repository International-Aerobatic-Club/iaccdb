class Admin::ContestsController < ApplicationController
  before_action :authenticate

  include Manny::Connect

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.includes(:manny_synch).order(start: :desc)
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

  # GET /manny_list
  def manny_list
    @records = []
    pull_contest_list(lambda do |rcd| 
      if !(rcd =~ /ContestList\>/)
        record = rcd.split("\t")
        synch = MannySynch.find_by_manny_number(record[0].to_i)
        record << (synch && synch.contest_id ? synch.contest_id : "no contest")
        @records << record
      end
    end)
    @records.sort! {|a,b| b[0].to_i <=> a[0].to_i }
  end

  def contest_params
    params.require(:contest).permit(:name, :city, :state, :start, :chapter,
      :director, :region)
  end

  def load_contest
    @contest = Contest.find(params[:id])
  end
end
