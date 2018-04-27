class Admin::PcResultsController < ApplicationController

before_action :authenticate

def index
  @contest = Contest.find(params[:contest_id])
  @pc_results = @contest.pc_results
end

def show
  @pc_results = PcResult.find(params[:id])
end

end
