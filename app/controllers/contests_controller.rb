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
    begin
      @c_results = @contest.results
    rescue
      @c_results = nil
    end

    respond_to do |format|
      format.html do
        if @c_results
          render :show
        else
          render :raw, :notice => "Results unavailable"
        end
      end
      format.xml  { render :xml => @contest }
    end
  end

end
