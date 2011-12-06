require 'lib/iac/constants'

class ContestsController < ApplicationController
  include IAC::Constants

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.order("start DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @contests }
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    #@contest.results #todo cache
    #pa = PCResults.find(:contest => @contest).order_by(:category, :category_rank)
    pa = Member.find_by_sql("select distinct m.*, f.category, f.aircat
      from members m, flights f, pilot_flights p
        where f.contest_id = #{@contest.id} and p.flight_id = f.id and
          m.id = p.pilot_id")
    @pilots = category_split(pa)
    @categories = category_list_sort(@pilots)
    ja = Judge.find_by_sql("select distinct j.*, f.category, f.aircat
      from judges j, flights f, pilot_flights p, scores s
      where f.contest_id = #{@contest.id} and p.flight_id = f.id and
        s.pilot_flight_id = p.id and j.id = s.judge_id")
    @judges = category_split(ja)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/new
  # GET /contests/new.xml
  def new
    @contest = Contest.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @contest }
    end
  end

  # GET /contests/1/edit
  def edit
    @contest = Contest.find(params[:id])
  end

  # POST /contests
  # POST /contests.xml
  def create
    @contest = Contest.new(params[:contest])

    respond_to do |format|
      if @contest.save
        format.html { redirect_to(@contest, :notice => 'Contest was successfully created.') }
        format.xml  { render :xml => @contest, :status => :created, :location => @contest }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /contests/1
  # PUT /contests/1.xml
  def update
    @contest = Contest.find(params[:id])

    respond_to do |format|
      if @contest.update_attributes(params[:contest])
        format.html { redirect_to(@contest, :notice => 'Contest was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @contest.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /contests/1
  # DELETE /contests/1.xml
  def destroy
    @contest = Contest.find(params[:id])
    @contest.destroy

    respond_to do |format|
      format.html { redirect_to(contests_url) }
      format.xml  { head :ok }
    end
  end
end
