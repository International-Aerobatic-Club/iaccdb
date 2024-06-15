class LiveResultsController < ApplicationController

  protect_from_forgery except: :last_upload

  def show
    @contest = Contest.find(params[:id])
    @contest.extend(Contest::ShowResults)
    @categories = @contest.category_results
    render layout: 'compact'
  end

  def last_upload

    respond_to do |format|
      format.js {
        render layout: false,
               locals: { timestamp: DataPost.where(contest_id: params[:id]).last&.created_at&.to_i || 0 }
      } # format.js
    end

  end

end
