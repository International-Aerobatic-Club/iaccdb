class Admin::JcResultsController < ApplicationController

before_filter :authenticate

def index
  @contest = Contest.find(params[:contest_id])
  @jc_results = @contest.jc_results
end

def show
  @jc_result = JcResult.find(params[:id])
  @contest = @jc_result.contest
end

end
