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


  # This method, inherited by all controller subclasses, configures the HTTP 1.1 Cache-Control header
  # which allows the entire page to be cached.
  #
  # Sample header: Cache-Control: max-age=60, public
  #
  # Usage: before_action: :make_cacheable, only: [:method1, :method2]
  #        (Note: The "only:' clause is optional)

  def make_cacheable
    expires_in 1.minutes, public: true if Rails.env.production?
    @cacheable = true
    request.session_options[:skip] = true
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
