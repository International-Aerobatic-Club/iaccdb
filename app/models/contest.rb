class Contest < ActiveRecord::Base
  has_many :flights, :dependent => :destroy

  def display
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end
end
