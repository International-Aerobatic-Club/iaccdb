class LiveResultsController < ApplicationController

  def show
    @contest = Contest.find(params[:id])
    @contest.extend(Contest::ShowResults)
    @categories = @contest.category_results
    render layout: 'compact'
  end

  def last_updated

  end

end
