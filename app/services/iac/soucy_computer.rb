# Computes L. Paul Soucy series results and leaves them in the database
# This computation works in phases.
# First, it gathers all pilots who have participated in more than one contest
# Second, computes best combination of two results for each pilot
# Third, if Nationals has been flown, adds Nationals results for
#   pilots who have one, and marks them eligible
# Fourth, ranks competitors based on their results and eligibility.
module Iac::SoucyComputer

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

    pilots = Member
      .joins(:pc_results => :contest)
      .where(
        "YEAR(contests.start) = ? AND contests.region != 'National' AND pc_results.category_id in (?)",
        @year, SoucyResult.valid_category_ids
      )
      .group('members.id')
      .having('COUNT(DISTINCT(pc_results.id)) > 1')

    soucies = pilots.all.collect { |pilot| engage_soucy_for_pilot(pilot) }
    trim_soucies(soucies)

    return soucies

  end

  # finds or creates soucy record for pilot
  # links pc_results for @year
  # returns the soucy record
  def engage_soucy_for_pilot(pilot)
    soucy = SoucyResult.where(:pilot_id => pilot.id, :year => @year).first_or_create
    soucy.collect_valid_non_nationals_results
  end

  # remove any soucies for year not in the list
  def trim_soucies(to_be_soucies)
    existing_soucies = SoucyResult.where(:year => @year).all
    to_remove = existing_soucies - to_be_soucies
    to_remove.each { |soucy| soucy.destroy }
  end

  def integrate_nationals
    nationals = Contest.where("YEAR(start) = ? AND region = 'National'", @year).all
    if nationals.present?
      @soucies.each { |soucy| soucy.integrate_national_result(nationals) }
    end
  end

end
