# Computes L. Paul Soucy series results and leaves them in the database
# This computation works in phases.
# First, it gathers all pilots who have participated in more than one contest
# Second, computes best combination of two results for each pilot
# Third, if Nationals has been flown, adds Nationals results for
#   pilots who have one, and marks them eligible
# Fourth, ranks competitors based on their results and eligibility.
module IAC
class SoucyComputer

def initialize (year)
  @year = year
end

# Compute the year's Soucy result
def recompute
  @soucies = soucies_for_pilots
  @soucies.each { |soucy| soucy.compute_best_pair }
  integrate_nationals
  RankComputer.compute_result_rankings(@soucies)
end

###
private
###

def soucies_for_pilots
  pilots = Member.joins(:pc_results => {:c_result => :contest}).where(
    "year(contests.start) = ? and contests.region != 'National'", @year).group(
    'members.id').having('1 < count(distinct(pc_results.id))')
  soucies = pilots.all.collect { |pilot| engage_soucy_for_pilot(pilot) }
  trim_soucies(soucies)
  soucies
end

# finds or creates soucy record for pilot
# links pc_results for @year
# returns the soucy record
def engage_soucy_for_pilot(pilot)
  soucy = SoucyResult.where(:pilot_id => pilot.id, :year => @year).first_or_create
  to_be_results = PcResult.joins(:c_result => :contest).where(
    "pilot_id = ? and contests.region != 'National' and year(contests.start) = ?",
    pilot.id, @year)
  existing_results = soucy.pc_results.all
  to_remove = existing_results - to_be_results
  to_add = to_be_results - existing_results
  to_remove.each { |pc_result| soucy.pc_results.delete(pc_result) }
  to_add.each { |pc_result| soucy.pc_results.push(pc_result) }
  soucy
end

# remove any soucies for year not in the list
def trim_soucies(to_be_soucies)
  existing_soucies = SoucyResult.where(:year => @year).all
  to_remove = existing_soucies - to_be_soucies
  to_remove.each { |soucy| soucy.destroy }
end

def integrate_nationals
  nationals = Contest.where("year(start) = ? and region = 'National'", @year).all
  if (1 < nationals.size)
    puts "MORE THAN ONE NATIONALS in #{@year}"
  end
  nationals = nationals.first
  if nationals
    @soucies.each { |soucy| soucy.integrate_national_result(nationals) }
  end
end

end
end
