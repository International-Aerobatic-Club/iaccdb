class CategorySynthesisService
  def self.synthesize_category(synthetic_category)
    sc = synthetic_category # shorthand
    reg_cat = sc.regular_category
    syn_cat = sc.find_or_create
    reg_flights = Flight.where(contest: sc.contest, category: reg_cat)
    sc.synthetic_category_flights.each do |name|
      reg_flight = Flight.find_by(
        contest: sc.contest, category: reg_cat, name: name
      )
      reg_flight.extend(FlightM::CopyToCategory)
      reg_flight.copy_to_category(syn_cat)
    end
    non_reg_names =
      sc.synthetic_category_flights - sc.regular_category_flights
    Flight.where(
      contest: sc.contest, category: reg_cat, name: non_reg_names
    ).each do |flight|
      flight.destroy!
    end
  end

  def self.synthesize_categories(contest)
    SyntheticCategory.where(contest: contest).each do |sc|
      self.synthesize_category(sc)
    end
  end
end
