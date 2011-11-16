require 'iac/rank_computer.rb'

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

  def results
    flights.each do |flight|
      IAC::RankComputer.computeFlight(flight)
    end
    self
  end
end

