class Category < ActiveRecord::Base
  has_many :jy_results

  def self.find_for_cat_aircat(cat, aircat)
    mycat = Category.find_by_category_and_aircat(cat, aircat)
    if !mycat
      if cat =~ /four minute/i
        mycat = Category.find_by_category_and_aircat('four minute', 'P')
      end
    end
    mycat
  end

end
