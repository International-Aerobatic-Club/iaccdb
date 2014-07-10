# Computes regional series results and leaves them in the database
# IAC P&P section 226 documents the regional series results computation procedure
# This computation works in phases.
# First, it computes every competitor's results in every category of every region.
# Second, it determines eligibility of every competitor in every region.
# Third, it ranks competitors based on their results and eligibility.
module IAC
class RegionalSeries
include IAC::Constants

# Compute every competitor's results in every region.
# Nationals competitors will have a result in every region.
# Other competitors will have a result in regions where they have participated in a contest.
# Competitors will have a result in each category they have competed
# H/C (for patch) results are ignored.
def self.compute_results (year)
end

# Compute every competitor's eligibility in every region.
# Does not currently account for chapter membership.
def self.compute_eligibility (year)
end

# Compute ranking for every competitor X region X category
def self.compute_ranking (year)
end

# Compute regional series results
def self.compute_regionals (year)
  compute_results year
  compute_eligibility year
  compute_ranking year
end

end #class
end #module
