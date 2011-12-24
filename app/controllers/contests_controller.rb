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

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @contest }
    end
  end

end
