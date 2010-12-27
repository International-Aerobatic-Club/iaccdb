class Contest < ActiveRecord::Base
  has_many :flights, :dependent => :destroy

  def display
    "#{name} category #{aircat} on #{start.to_s}"
  end
end
