class ContestsController < ApplicationController

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
    @c_results = @contest.c_results.sort { |a,b| a.category.sequence <=> b.category.sequence }

    respond_to do |format|
      format.html do
        if @c_results && !@c_results.empty?
          render :show
        else
          render :raw, :notice => "Results unavailable"
        end
      end
      format.xml  { render :xml => @contest }
    end
  end

end
