# Computes regional series results and leaves them in the database
# IAC P&P section 226 documents the regional series results computation procedure
# This computation works in phases.
# First, it computes every competitor's results in every category of every region.
# Second, it determines eligibility of every competitor in every region.
# Third, it ranks competitors based on their results and eligibility.
module IAC
  class RegionalSeries
    include IAC::Region

    def required_contest_count(region, year)
      if (year < 2018)
        (/NorthWest/i =~ region) ? 2 : 3;
      else
        3
      end
    end

    # Before 2019, only non-hc results qualify
    # From 2019, results marked HC for solo in category do qualify
    def hc_qualified_results(contest)
      if (contest.year < 2019)
        contest.pc_results.competitive
      else
        contest.pc_results.non_comp_allowed
      end
    end

    # Accumulate pc_results for contest onto regional_pilots
    def accumulate_contest (year, region, contest)
      hc_qualified_results(contest).each do |pc_result|
        if pc_result.is_five_cat
          regional_pilot = RegionalPilot.find_or_create_given_result(
             year, region, pc_result.category.id, pc_result.pilot.id)
          regional_pilot.pc_results << pc_result
        end
      end
    end

    # Compute every competitor's results in the given region.
    # Nationals competitors will have a result in every region.
    # Other competitors will have a result in regions where they have participated in a contest.
    # Competitors will have a result in each category they have competed
    # Does not currently ignore H/C (for patch) results
    def compute_results (year, region)
      RegionalPilot.where(:year => year, :region => region).destroy_all
      #first find the contests in the region 
      contests = Contest.where(['year(start) = ? and region = ?', year, region])
      contests.each do |contest|
        accumulate_contest year, region, contest
      end
      nationals = Contest.where(['year(start) = ? and region = "National"', year])
      nationals.each do |contest|
        accumulate_contest year, region, contest
      end
      RegionalPilot.where(:year => year, :region => region).each do |rp|
        best_pct = 0;
        best_combo = [];
        apc = rp.pc_results.all
        pc_ct = apc.count
        pc_req = required_contest_count(region, year)
        pc_use = pc_ct < pc_req ? pc_ct : pc_req
        apc.to_a.combination(pc_use) do |c|
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
          rp.save!
        end
      end
    end

    # Compute regional series results given year and region
    def compute_regional (year, region)
      compute_results year, region
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
  end
end
