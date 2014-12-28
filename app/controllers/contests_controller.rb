class ContestsController < ApplicationController

  # GET /contests
  # GET /contests.xml
  def index
    @contests = Contest.order("start DESC")
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    @c_results = @contest.c_results.sort { |a,b| a.category.sequence <=> b.category.sequence }
    if @c_results && !@c_results.empty?
      render :show
    else
      render :raw, :notice => "Results unavailable"
    end
  end

end
