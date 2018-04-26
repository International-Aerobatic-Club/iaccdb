class Admin::FailuresController < ApplicationController
  before_action :authenticate

  def index
    @failures = Failure.includes(:contest).order("created_at DESC")
  end

  def show
    @failure = Failure.includes(:contest).find(params[:id])
  end

  def destroy
    @failure = Failure.find(params[:id])
    @failure.destroy
    redirect_to(admin_failures_url)
  end
end
