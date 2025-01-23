module AuthHelper

  include ActiveSupport

  def current_role
    @current_role ||= :visitor
  end

  def check_auth(user_name, password, role = :admin)
    user = UserList.find_by_name(user_name)
    have_auth = user && user[:password] == password
    @current_role = have_auth ? user[:role].to_sym : :visitor
    roles = [:admin] + [role].flatten.compact.map(&:to_sym)
    have_auth && roles.member?(current_role)
  end

  class UserList
    class << self
      attr_accessor :users

      def users
        Rails.application.credentials.dig(:users)
      end

      def find_by_name(user_name)
        Rails.application.credentials.dig(:users, user_name.to_sym)
      end

    end
  end
end
