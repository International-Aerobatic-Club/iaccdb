class ContestsController < ApplicationController
  before_action :require_contest_admin, except: %i[index show]
  skip_before_action :verify_authenticity_token, only: %i[create update destroy]
  before_action :make_cacheable, only: %i[show]

  # GET /contests
  def index
    @years = Contest.select("DISTINCT YEAR(start) AS year_num").map(&:year_num).sort.reverse
    @year = params[:year] || default_year(@years.first)
    @contests = Contest.where('YEAR(start) = ? AND start <= NOW()', @year).order(start: :desc).includes(:flights)
    @future_contests = Contest.where('YEAR(start) = ? AND start > NOW()', @year).order(:start)
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
    if (contest.valid?)
      render json: contest
    else
      render json: { errors: contest.errors.full_messages }, status: :bad_request
    end
  end

  # PUT /contests/1
  def update
    contest = fetch_contest
    contest.update(contest_params)
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

  def default_year(latest_contest_year)
    current_year = Time.now.year
    if latest_contest_year
      current_year < latest_contest_year ? current_year : latest_contest_year
    else
      current_year
    end
  end
end
