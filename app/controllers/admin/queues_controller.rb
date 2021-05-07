class Admin::QueuesController < ApplicationController
  before_action :authenticate

  def index
    @jobs = Delayed::Job.order(created_at: :desc)
  end

  def show
    @job = Delayed::Job.find(params[:id])
  end
end
