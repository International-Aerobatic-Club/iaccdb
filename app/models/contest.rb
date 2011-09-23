class Contest < ActiveRecord::Base
  has_many :flights, :dependent => :destroy

  def to_s
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end

  def place
    "#{city}, #{state} (#{region})"
  end

  def sobriquet
    if !name.empty?
      name
    else
      id
    end
  end
end
