class CategoryFixup < ActiveRecord::Migration
  def self.up
    four_minute_cat = Category.find_by_category('four minute')
    Flight.all.each do |flight|
      if (!flight.category_id)
        cat = Category.find_by_category_and_aircat(flight.category, flight.aircat)
        cat ||= four_minute_cat
        if (cat)
          flight.category_id = cat.id
          flight.save
        else
          puts "Unable category for flight #{flight.to_s} with category #{flight.category} aircat #{flight.aircat}"
        end
      end
    end
    CResult.all.each do |c_result|
      if (!c_result.category_id)
        cat = Category.find_by_category_and_aircat(c_result.category, c_result.aircat)
        cat ||= four_minute_cat
        if (cat)
          c_result.category_id = cat.id
          c_result.save
        else
          puts "Unable category for c_result #{c_result.to_s} with category #{c_result.category} aircat #{c_result.aircat}"
        end
      end
    end
  end

  def self.down
  end
end
