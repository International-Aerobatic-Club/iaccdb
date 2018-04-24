class Admin::ContestsController < Admin::AdminController
  include Manny::Connect
  before_filter :authenticate
  load_and_authorize_resource

  # GET /contests
  # GET /contests.xml
  def index
    @contests = @contests.includes(:manny_synch).order("start DESC")
  end

  # GET /contests/1/edit
  def edit
    #@contest = Contest.find(params[:id])
  end

  # PUT /contests/1
  def update
    #@contest = Contest.find(params[:id])

    if @contest.update_attributes(params[:contest])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def destroy
    #@contest = Contest.find(params[:id])
    @contest.destroy

    redirect_to(admin_contests_url)
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    #@contest = Contest.find(params[:id])
    # admin/show.html.erb
  end

  # GET /contests/1/recompute
  # GET /contests/
  def recompute
    #@contest = Contest.find(params[:id])
    Delayed::Job.enqueue Jobs::ComputeFlightsJob.new(@contest)
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
end
