class Admin::MannySynchsController < ApplicationController
  before_filter :authenticate

  def index
    @manny_synchs = MannySynch.includes(:contest).order("synch_date DESC")
  end

  def destroy
    @manny = MannySynch.find(params[:id])
    @manny.contest.destroy if @manny.contest
    @manny.destroy

    redirect_to(admin_manny_synchs_url)
  end

end
