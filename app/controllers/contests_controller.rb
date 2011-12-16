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
    @c_results = @contest.results
    @judges = {}
    @c_results.each do |c_result|
      @judges[c_result] = Judge.find_by_sql("select distinct j.* 
      from judges j, pc_results r, pf_results f, scores s
      where r.c_result_id = #{c_result.id} and
        f.pc_result_id = r.id and 
        s.pilot_flight_id = f.pilot_flight_id and 
        j.id = s.judge_id")
    end

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

end
