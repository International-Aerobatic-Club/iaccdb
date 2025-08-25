module Iac::Region

  def is_national(region)
    /National/i =~ region
  end

end
