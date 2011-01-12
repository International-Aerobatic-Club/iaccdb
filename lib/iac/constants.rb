module IAC
module Constants
  CONTEST_CATEGORIES = %w{ Primary Sportsman Intermediate Advanced Unlimited }
  CATEGORY_NAMES = CONTEST_CATEGORIES + %w{ Four\ Minute\ Free }
  FLIGHT_NAMES = %w{ Known Free Unknown Unknown\ 2 }
  AIRPLANE_CATEGORIES = %w{ P G }
  POWER_CATEGORY = 'P'
  GLIDER_CATEGORY = 'G'

  def airplane_category_name(aircat)
    case aircat 
      when POWER_CATEGORY then 'Power'
      when GLIDER_CATEGORY then 'Glider'
      else ''
    end
  end
end
end
