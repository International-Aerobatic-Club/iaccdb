class Admin::JcResultsController < ApplicationController

before_filter :authenticate

def index
  @contest = Contest.find(params[:contest_id])
  @jc_results = @contest.jc_results
end

def show
  @jc_results = JcResult.find(params[:id])
end

end
