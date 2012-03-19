class Admin::CResultsController < ApplicationController

before_filter :authenticate

def index
  @contest = Contest.find(params[:contest_id])
  @c_results = @contest.c_results
end

def show
  @c_results = CResult.find(params[:id])
end

end
