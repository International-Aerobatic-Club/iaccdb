class ContestsController < ApplicationController
  before_action :require_contest_admin
  skip_before_action :require_contest_admin,
    only: [:index, :show]
  skip_before_action :verify_authenticity_token,
    only: [:create, :update, :destroy]

  # GET /contests
  def index
    @years = Contest.select("distinct year(start) as anum").all.collect { |contest| contest.anum }
    @years.sort!{|a,b| b <=> a}
    @year = params[:year] || @years.first
    @contests = Contest.where(
      'year(start) = ? and start <= now()', @year
    ).order("start DESC")
    @future_contests = Contest.where(
      'year(start) = ? and now() < start', @year
    ).order("start ASC")
  end

  # GET /contests/1
  def show
    @contest = Contest.find(params[:id])
    @contest.extend(Contest::ShowResults)
    @categories = @contest.category_results
    render :show
  end

  # POST /contests
  def create
    contest = Contest.create(contest_params)
    if (contest)
      render json: contest
    else
      head :bad_request
    end
  end

  # PUT /contests/1
  def update
    contest = fetch_contest
    contest.update_attributes(contest_params)
    render json: contest
  end

  # DELETE /contests/1
  def destroy
    contest = fetch_contest
    contest.destroy
    head :ok
  end

  private

  def require_contest_admin
    authenticate(:contest_admin)
  end

  def contest_params
    @contest_params ||= params.require(:contest).permit(
      :name, :start, :city, :state, :chapter, :director, :region)
  end

  def fetch_contest
    Contest.find(params[:id])
  end
end
