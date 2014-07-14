# Computes regional series results and leaves them in the database
# IAC P&P section 226 documents the regional series results computation procedure
# This computation works in phases.
# First, it computes every competitor's results in every category of every region.
# Second, it determines eligibility of every competitor in every region.
# Third, it ranks competitors based on their results and eligibility.
module IAC
class RegionalSeries

def self.is_national(region)
  /national/i =~ region
end

# Accumulate pc_results for contest onto regional_pilots
def self.accumulate_contest (contest)
  puts "..Including #{contest.year_name} #{contest.place}"
  contest.c_results.each do |c_result|
    c_result.pc_results.each do |pc_result|
      regional_pilot = RegionalPilot.find_or_create_given_pc_result pc_result
      regional_pilot.pc_results << pc_result
    end
  end
end

# Compute every competitor's results in the given region.
# Nationals competitors will have a result in every region.
# Other competitors will have a result in regions where they have participated in a contest.
# Competitors will have a result in each category they have competed
# Does not currently ignore H/C (for patch) results
def self.compute_results (year, region)
  #first find the contests in the region 
  contests = Contest.where("year(start) = #{year} and region = '#{region}'")
  contests.each do |contest|
    accumulate_contest contest
  end
  nationals = Contest.where("year(start) = #{year} and region = 'National'")
  nationals.each do |contest|
    accumulate_contest contest
  end
end

# Compute every competitor's eligibility in every region.
# Does not currently account for chapter membership.
def self.compute_eligibility (year, region)
end

# Compute ranking for every competitor X region X category
def self.compute_ranking (year, region)
end

# Compute regional series results given year and region
def self.compute_regional (year, region)
  puts "Computing regional series results for region #{region}, contest year #{year}"
  compute_results year, region
  compute_eligibility year, region
  compute_ranking year, region
end

# Compute regional series results given contest
def self.compute_regional_for_contest (contest)
  if is_national(contest.region)
    compute_all_regions contest.year
  else
    compute_regional contest.year, contest.region
  end
end

# Compute all regions. Necessary after the Nationals.
def self.compute_all_regions (year)
  contests = Contest.where('year(start) = ?', year)
  regions = contests.inject([]) { |ra, c| ra << c.region }
  regions.uniq!
  regions.reject! { |r| is_national(r) }
  regions.each { |r| compute_regional(year, r) }
end

end #class
end #module
