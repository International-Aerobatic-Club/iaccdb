class Category < ApplicationRecord
  has_and_belongs_to_many :flights
  has_many :region_pilots
  has_many :results
  has_many :jc_results, dependent: :destroy
  has_many :pc_results, dependent: :destroy
  has_many :jy_results, dependent: :destroy
  has_many :free_program_ks

  def self.find_for_cat_aircat(cat, aircat)
    cat = cat.downcase.strip
    if /Minute|Four/i =~ cat
      aircat = 'F'
    else
      aircat = aircat.strip[0].upcase
    end
    mycat = Category.where(category: cat, aircat: aircat).first
    if !mycat
      if /Pri|Bas/i =~ cat
        mycat = Category.find_by_category_and_aircat('primary', aircat)
      elsif /Spn|Sport|Standard/i =~ cat
        mycat = Category.find_by_category_and_aircat('sportsman', aircat)
      elsif /Adv/i =~ cat
        mycat = Category.find_by_category_and_aircat('advanced', aircat)
      elsif /Imdt|Intmdt/i =~ cat
        mycat = Category.find_by_category_and_aircat('intermediate', aircat)
      elsif /Unl/i =~ cat
        mycat = Category.find_by_category_and_aircat('unlimited', aircat)
      elsif /Minute|Four/i =~ cat
        mycat = Category.find_by_category_and_aircat('four minute', 'F')
      end
    end
    mycat
  end

  def is_primary
    /primary|basic/i =~ self.category
  end

  def to_s
    name
  end

  def self.options
    [[ 'Select One', nil ]] + self.all.map{ |c| [ c.name, c.id] }
  end

end
