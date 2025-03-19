# National Point Series, see: https://www.iac.org/national-point-series-championship-iac-npsc

# Each record holds the ranking of one pilot in one category
class LeoRank < Result

  # Build a list of categories
  def self.categories(year)

    # Power only, and non-synthetic (which was only used once, for Adv Team Nationals results)
    query = Category.where(aircat: 'P', synthetic: false)

    # Primary was not eligible for a Leo award until 2023
    query = query.where.not(category: 'primary') if year.to_i < 2023

    # Return the query, sorted in increasing order of difficulty, from Primary (or Sportsman) thru Unlimited
    query.order(:sequence)

  end

end
