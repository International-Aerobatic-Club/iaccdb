class ContestsController < ApplicationController

  # GET /contests
  # GET /contests.xml
  def index
    @years = Contest.select("distinct year(start) as anum").all.collect { |contest| contest.anum }
    @years.sort!{|a,b| b <=> a}
    @year = params[:year] || @years.first
    @contests = Contest.where('year(start) = ?', @year).order("start DESC")
    respond_to do |format|
      format.html
      format.xml do
        render xml: @contests.to_xml
      end
      format.json do
        render json: @contests.as_json
      end
    end
  end

  # GET /contests/1
  # GET /contests/1.xml
  def show
    @contest = Contest.find(params[:id])
    @c_results = @contest.c_results.sort { |a,b| a.category.sequence <=> b.category.sequence }
    if @c_results && !@c_results.empty?
      respond_to do |format|
        format.html
          render :show
        format.xml do
          render xml: @contest.to_xml
        end
        format.json do
          render json: @contest.as_json
        end
      end
    else
      render :raw, :notice => "Results unavailable"
    end
  end

end
