class CategorySynthesisService
  def self.synthesize_category(synthetic_category)
    sc = synthetic_category # shorthand
    reg_cat = sc.regular_category
    syn_cat = sc.find_or_create
    reg_flights = reg_cat.flights.where(contest: sc.contest)
    sc.synthetic_category_flights.each do |name|
      reg_flight = reg_flights.find_by(name: name)
      reg_flight.categories << syn_cat if reg_flight
    end
    non_reg_names =
      sc.synthetic_category_flights - sc.regular_category_flights
    reg_flights.where(name: non_reg_names).each do |flight|
      flight.categories.delete(reg_cat)
    end
  end

  def self.synthesize_categories(contest)
    SyntheticCategory.where(contest: contest).each do |sc|
      self.synthesize_category(sc)
    end
  end
end
