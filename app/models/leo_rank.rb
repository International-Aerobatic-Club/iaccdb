# National Point Series, see: https://www.iac.org/national-point-series-championship-iac-npsc

# Each record holds the ranking of one pilot in one category
class LeoRank < Result

  def self.categories
    Category.where(aircat: 'P', synthetic: false).order(:sequence)
  end

end
