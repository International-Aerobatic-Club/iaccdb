class Member < ActiveRecord::Base
  def display
    "#{given_name} #{family_name}, iac #{iac_id}"
  end
end
