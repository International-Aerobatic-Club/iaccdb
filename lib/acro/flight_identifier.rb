module ACRO
module FlightIdentifier
  def detect_flight_category(description)
    cat = nil
    if /Four|Minute/i =~ description
      cat = 'Four Minute' 
    else
      IAC::Constants::CONTEST_CATEGORIES.each do |catName|
        cat = catName if Regexp.new(catName, 'i') =~ description
      end
    end
    if !cat
      if /Pri|Begin|Basic/i =~ description
        cat = 'Primary'
      elsif /Sport|Standard/i =~ description || /Spn/i =~ description
        cat = 'Sportsman'
      elsif /Adv/i =~ description
        cat = 'Advanced'
      elsif /Imdt/i =~ description || /Intmdt/i =~ description
        cat = 'Intermediate'
      elsif /Unl/i =~ description
        cat = 'Unlimited'
      elsif /Minute|Four/i =~ description
        cat = 'Four Minute'
      end
    end
    cat
  end

  def detect_flight_name(description)
    name = nil
    if /Team/i =~ description
      name = 'Team Unknown' 
    elsif /Primary|Sportsman/ =~ detect_flight_category(description)
      if /#1|1st/ =~ description
        name = 'Flight 1'
      elsif /#2|2nd|Programme 2/ =~ description
        name = 'Flight 2'
      elsif /#3|3rd|Programme 3/ =~ description
        name = 'Flight 3'
      end
    end
    if !name
      IAC::Constants::FLIGHT_NAMES.each do |fltName|
        name = fltName if Regexp.new(fltName, 'i') =~ description
      end
    end
    name
  end

  def detect_flight_aircat(description)
    aircat = nil
    if /Power|Four|Minute|Primary|Beginners|Basic/i =~ description
      aircat = IAC::Constants::POWER_CATEGORY
    elsif /Glider/i =~ description
      aircat = IAC::Constants::GLIDER_CATEGORY
    end 
    aircat
  end
end
end
