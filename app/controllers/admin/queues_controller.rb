class Admin::QueuesController < ApplicationController
  before_filter :authenticate

  def index
    @jobs = Delayed::Job.order('created_at DESC')
  end

  def show
    @job = Delayed::Job.find(params[:id])
  end
end
