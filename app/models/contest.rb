class Contest < ActiveRecord::Base
  def display
    "#{name} category #{aircat} on #{start.to_s}"
  end
end
