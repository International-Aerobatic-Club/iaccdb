class Admin::MannySynchsController < ApplicationController
  include Manny::Connect

  before_action :authenticate

  def index
    @manny_synchs = MannySynch.includes(:contest).order("manny_number DESC")
  end

  def destroy
    @manny = MannySynch.find(params[:id])
    @manny.contest.destroy if @manny.contest
    @manny.destroy
    redirect_to admin_manny_synchs_url 
  end

  def retrieve
    Delayed::Job.enqueue Jobs::RetrieveMannyJob.new(params[:manny_number])
    flash[:notice] = "Queued manny number #{params[:manny_number]} for retrieval."
    redirect_to admin_manny_synchs_url
  end

  def show
    @manny_number = params[:manny_number]
    @text = []
    pull_contest(@manny_number, lambda { |rcd| @text << rcd })
  end

end
