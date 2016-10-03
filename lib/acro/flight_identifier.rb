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
    flight_category = detect_flight_category(description)
    if /Team/i =~ description
      name = 'Team Unknown' 
    elsif /Four|Minute/ =~ description
      name = 'Four Minute Free'
    elsif /Primary|Sportsman/ =~ flight_category
      if /#2|2nd|Programme 2/ =~ description
        name = 'Flight 2'
      elsif /#3|3rd|Programme 3/ =~ description
        name = 'Flight 3'
      elsif /#1|1st|Programme 1|Known/ =~ description
        if /Primary/ =~ flight_category
          name = 'Flight 1'
        else
          name = 'Known'
        end
      end
    elsif /Intermediate/ =~ flight_category
      if /#2|2nd|Programme 2|Free/ =~ description
        name = 'Free'
      elsif /#3|3rd|Programme 3|Unknown/ =~ description
        name = 'Unknown'
      elsif /#1|1st|Programme 1|Known/ =~ description
        name = 'Known'
      end
    else
      if /Free/ =~ description
        if /Unknown/ =~ description
          if /1/ =~ description
            name = 'Free Unknown 1'
          elsif /2/ =~ description
            name = 'Free Unknown 2'
          else
            name = 'Free Unknown'
          end
        elsif /Known/ =~ description
          name = 'Free Known'
        else
          name = 'Free'
        end
      elsif /Unknown/ =~ description
        # but not "Free"
        if /1/ =~ description
          name = 'Free Unknown 1'
        elsif /2/ =~ description
          name = 'Free Unknown 2'
        else
          name = 'Unknown'
        end
      elsif /Known/ =~ description
        # but not "Free"
        name = "Known"
      elsif /#2|2nd|Programme 2/ =~ description
        name = 'Free'
      elsif /#3|3rd|Programme 3/ =~ description
        name = 'Unknown'
      elsif /#1|1st|Programme 1/ =~ description
        name = 'Known'
      end
    end
    name
  end

  def detect_flight_aircat(description)
    aircat = nil
    if /Four|Minute/i =~ description
      aircat = IAC::Constants::FOUR_MINUTE_CATEGORY
    elsif /Power|Primary|Beginners|Basic/i =~ description
      aircat = IAC::Constants::POWER_CATEGORY
    elsif /Glider/i =~ description
      aircat = IAC::Constants::GLIDER_CATEGORY
    end
    aircat
  end
end
end
