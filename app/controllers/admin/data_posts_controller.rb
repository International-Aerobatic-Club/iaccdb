class Admin::DataPostsController < ApplicationController
  before_filter :authenticate

  def index
    @data_posts = DataPost.order('created_at desc').all
  end

  def show
    @data_post = DataPost.find(params[:id])
  end

  def download
    @data_post = DataPost.find(params[:id])
    send_data @data_post.data, 
      :content_type => 'text/xml', 
      :filename => "JaSPer_post_IACCDB_#{@data_post.id}.xml"
  end

  def resubmit
    Delayed::Job.enqueue Jobs::ProcessJasperJob.new(params[:id])
    flash[:notice] = "Post queued for processing"
    redirect_to :action => 'show' 
  end
end
