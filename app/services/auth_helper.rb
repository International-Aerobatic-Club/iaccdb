module AuthHelper
  def current_role
    @current_role ||= :visitor
  end

  def check_auth(user_name, password, role = :admin)
    user = UserList.find_by_name(user_name)
    have_auth = user && user['password'] == password
    @current_role = have_auth ? user['role'].to_sym : :visitor
    roles = [:admin] + [role].flatten.compact.map(&:to_sym)
    have_auth && roles.member?(current_role)
  end

  class UserList
    class << self
      attr_accessor :users

      def users
        @users ||=
          Rails.application.secrets['users'] ||
          YAML.load_file('config/admin.yml')['users'] ||
          []
      end

      def find_by_name(user_name)
        users.find { |u| u['name'] == user_name }
      end

      def first_with_role(role)
        role = role ? role.to_sym : :admin
        users.find { |u| u['role'].to_sym == role }
      end
    end
  end
end
