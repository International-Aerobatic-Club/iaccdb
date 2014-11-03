module IAC
module Region
  def self.is_national(region)
    /National/i =~ region
  end
end
end

