class ContestsController < ApplicationController

  # GET /contests
  def index
    @years = Contest.select("distinct year(start) as anum").all.collect { |contest| contest.anum }
    @years.sort!{|a,b| b <=> a}
    @year = params[:year] || @years.first
    @contests = Contest.where('year(start) = ?', @year).order("start DESC")
  end

  # GET /contests/1
  def show
    @contest = Contest.find(params[:id])
    @contest.extend(Contest::ShowResults)
    @categories = @contest.category_results
    render :show
  end

end
