# Computes regional series results and leaves them in the database
# IAC P&P section 226 documents the regional series results computation procedure
# This computation works in phases.
# First, it computes every competitor's results in every category of every region.
# Second, it determines eligibility of every competitor in every region.
# Third, it ranks competitors based on their results and eligibility.
module IAC
class RegionalSeries
include IAC::Region

def required_contest_count(region)
  (/NorthWest/i =~ region) ? 2 : 3;
end

# Accumulate pc_results for contest onto regional_pilots
def accumulate_contest (year, region, contest)
  puts "..Including #{contest.year_name} #{contest.place}"
  contest.c_results.each do |c_result|
    c_result.pc_results.each do |pc_result|
      #puts "...finding regional pilot for #{pc_result.pilot}"
      regional_pilot = RegionalPilot.find_or_create_given_result(
         year, region, pc_result.category.id, pc_result.pilot.id)
      #puts "....regional pilot is #{regional_pilot}"
      regional_pilot.pc_results << pc_result
      #puts "....regional pilot contest count is #{regional_pilot.pc_results.count}"
    end
  end
end

# Compute every competitor's results in the given region.
# Nationals competitors will have a result in every region.
# Other competitors will have a result in regions where they have participated in a contest.
# Competitors will have a result in each category they have competed
# Does not currently ignore H/C (for patch) results
def compute_results (year, region)
  RegionalPilot.destroy_all(:year => year, :region => region)
  #first find the contests in the region 
  contests = Contest.where("year(start) = #{year} and region = '#{region}'")
  contests.each do |contest|
    accumulate_contest year, region, contest
  end
  nationals = Contest.where("year(start) = #{year} and region = 'National'")
  nationals.each do |contest|
    accumulate_contest year, region, contest
  end
  RegionalPilot.where(:year => year, :region => region).each do |rp|
    best_pct = 0;
    best_combo = [];
    apc = rp.pc_results.all
    pc_ct = apc.count
    pc_req = required_contest_count(region)
    pc_use = pc_ct < pc_req ? pc_ct : pc_req
    apc.combination(pc_use) do |c|
      pts_earned = c.inject(0) { |pts, pcr| pts + pcr.category_value }
      pts_possible = c.inject(0) { |pts, pcr| pts + pcr.total_possible }
      pct = pts_earned * 100.0 / pts_possible
      if best_pct < pct
        best_pct = pct
        best_combo = c
      end
    end
    rp.update_attributes(:percentage => best_pct, :qualified => (pc_use == pc_req))
  end
end

# Compute every competitor's eligibility in region.
# Does not currently account for chapter membership.
def compute_eligibility (year, region)
  #RegionalPilot.where(:year => year, :region => region).update_all(:qualified => true)
  # already accomplished by compute_results
end

# Compute ranking for every competitor X category in region
def compute_ranking (year, region)
  #RegionalPilot.where(:year => year, :region => region).update_all(:rank => 1)
  regional_pilots = RegionalPilot.where(:year => year, :region => region).order(
    'qualified desc, percentage desc')
  cat_pilots = regional_pilots.group_by { |p| p.category_id }
  cat_pilots.each do |cat, pilots|
    rank = 1
    next_rank = 2
    prev_qual = false
    prev_pct = 0
    pilots.each do |rp|
      rp.rank = rank
      rank = next_rank if prev_qual != rp.qualified || prev_pct != rp.percentage
      next_rank += 1
      prev_qual = rp.qualified
      prev_pct = rp.percentage
      rp.save
    end
  end
end

# Compute regional series results given year and region
def compute_regional (year, region)
  puts "Computing regional series results for region #{region}, contest year #{year}"
  compute_results year, region
  compute_eligibility year, region
  compute_ranking year, region
end

# Compute regional series results given contest
def compute_regional_for_contest (contest)
  if is_national(contest.region)
    compute_all_regions contest.year
  else
    compute_regional contest.year, contest.region
  end
end

# Compute all regions. Necessary after the Nationals.
def compute_all_regions (year)
  contests = Contest.where('year(start) = ?', year)
  regions = contests.inject([]) { |ra, c| ra << c.region }
  regions.uniq!
  regions.reject! { |r| is_national(r) }
  regions.each { |r| compute_regional(year, r) }
end

end #class
end #module
