class Admin::FailuresController < Admin::AdminController
  before_filter :authenticate
  load_and_authorize_resource

  def index
    @failures = @failures.includes(:contest).order("created_at DESC")
  end

  def show
  end

  def destroy
    @failure.destroy
    redirect_to(admin_failures_url)
  end
end
