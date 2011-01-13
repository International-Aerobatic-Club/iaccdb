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

  def category_name(cat, aircat)
    "#{cat}#{' Glider' if aircat == GLIDER_CATEGORY}"
  end

  # given an Array of Hash element, where each element contains 
  # a :category and :aircat field, return a new Hash of arrays
  # that sorts the elements of the original array into sub-arrays
  # hashed on category
  # input array [ 
  #   {:category => 'Advanced', :aircat => 'P', :pilot => 'D'},
  #   {:category => 'Intermediate', :aircat => 'P', :pilot => 'A'},
  #   {:category => 'Intermediate', :aircat => 'G', :pilot => 'C'},
  #   {:category => 'Advanced', :aircat => 'P', :pilot => 'E'},
  #   {:category => 'Intermediate', :aircat => 'P', :pilot => 'B'},
  #   {:category => 'Unlimited', :aircat => 'P', :pilot => 'F'}
  # ]
  # output Hash {
  #   'Intermediate' => [
  #     {:category => 'Intermediate', :aircat => 'P', :pilot => 'A'},
  #     {:category => 'Intermediate', :aircat => 'P', :pilot => 'B'},
  #   ],
  #   'Intermediate Glider' => [
  #     {:category => 'Intermediate', :aircat => 'G', :pilot => 'C'},
  #   ],
  #   'Advanced' => [
  #     {:category => 'Advanced', :aircat => 'P', :pilot => 'D'},
  #     {:category => 'Advanced', :aircat => 'P', :pilot => 'E'},
  #   ],
  #   'Unlimited' => [
  #     {:category => 'Unlimited', :aircat => 'P', :pilot => 'F'}
  #   ]}
  def category_split(catdata)
    hashed = {}
    catdata.each do |e|
      key = category_name(e[:category], e[:aircat])
      v = hashed[key] || Array.new
      v << e
      hashed[key] = v
    end
    hashed
  end

  # given Hash result of category_split, return array of keys in
  # category order
  # input Hash {
  #   'Advanced' => [
  #     {:category => 'Advanced', :aircat => 'P', :pilot => 'D'},
  #     {:category => 'Advanced', :aircat => 'P', :pilot => 'E'},
  #   ],
  #   'Intermediate' => [
  #     {:category => 'Intermediate', :aircat => 'P', :pilot => 'A'},
  #     {:category => 'Intermediate', :aircat => 'P', :pilot => 'B'},
  #   ],
  #   'Intermediate Glider' => [
  #     {:category => 'Intermediate', :aircat => 'G', :pilot => 'C'},
  #   ],
  #   'Unlimited' => [
  #     {:category => 'Unlimited', :aircat => 'P', :pilot => 'F'}
  #   ]}
  # output array [ 
  #   'Intermediate',
  #   'Intermediate Glider',
  #   'Advanced',
  #   'Unlimited'
  # ]
  def category_list_sort(hashed)
    cat_list = []
    CATEGORY_NAMES.each do |cat|
      AIRPLANE_CATEGORIES.each do |aircat|
        key = category_name(cat, aircat)
        cat_list << key if hashed.has_key? key
      end
    end
    cat_list
  end

end
end
