class ApplicationController < ActionController::Base
  include AuthHelper
  protect_from_forgery :with => :exception
  rescue_from ActiveRecord::RecordNotFound, :with => :record_not_found

  # authenticate interactively with browser credentials query
  def authenticate(role = nil)
    authenticate_or_request_with_http_basic do |user_name, password|
      check_auth(user_name, password, role)
    end
  end

private

  def record_not_found
    respond_to do |format|
      format.html { render plain: "Not Found", :status => :not_found }
      format.json { render json: { errors: 'not found' },
        :status => :not_found }
    end
  end
end
