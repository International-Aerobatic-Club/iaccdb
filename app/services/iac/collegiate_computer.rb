# Computes team and individual results and leaves them in the database
class Iac::CollegiateComputer

  include Iac

  def initialize (year)
    @year = year.to_i
  end

  def recompute
    recompute_individual
    recompute_team
  end

  # Compute the year's team result
  # For each collegieate team
  #   Extract list of pilots
  #   Extract list of contests for each pilot
  #   Determine qualification
  #   Determine best score combination
  def recompute_team
    teams = CollegiateResult.where(year: @year).all
    teams.each do |team|
      ctc = CollegiateTeamComputer.new(team.pilot_contests)
      result = ctc.compute_result
      team.qualified = result.qualified
      team.points = result.total
      team.points_possible = result.total_possible
      team.update_results(result.combination)
      team.save!
    end
    RankComputer.compute_result_rankings(teams)
  end

  # Compute the year's individual results
  def recompute_individual
    cic = CollegiateIndividualComputer.new(@year)
    cic.recompute
    results = CollegiateIndividualResult.where(year: @year).all
    RankComputer.compute_result_rankings(results)
  end

  def self.non_comp_allowed?(year)
    2018 < year
  end

  # find PcResult records for given pilot and year
  # filter or do not filter according to HC (competitive)
  def self.pilot_results(pilot, year)
    results = non_comp_allowed?(year) ? PcResult.non_comp_allowed : PcResult.competitive
    results.joins(:contest).where(pilot: pilot).where('YEAR(contests.start) = ?', year)
  end

  ###
  private
  ###

  # Sets team qualified boolean result
  # Count of pilots participating is three or more and
  # Three contests with three pilots and
  # Three contests with at least one non-Primary pilot
  def compute_qualification(team, pilots, pilot_contests)
    if 3 <= pilots.size
      contests_properties = gather_contest_properties(pilot_contests)
      non_primary_participant_occurrence_count = 0
      three_or_more_pilot_occurrence_count = 0
      contests_properties.each do |contest|
        non_primary_participant_occurrence_count += 1 if(
          contest[:has_non_primary])
        three_or_more_pilot_occurrence_count += 1 if(
          3 <= contest[:pilot_count])
      end
      team.qualified = 3 <= non_primary_participant_occurrence_count &&
                       3 <= three_or_more_pilot_occurrence_count
    else
      team.qualified = false
    end
  end

  # pilot_contests is hash of pilot (member)  => [ array of pc_result ]
  # return an array of hashes, one for each unique contest found in pilot_contests
  # each hash contains keys:
  #   :has_non_primary boolean true if one pilot flew the contest not in Primary
  #   :pilot_count integer count of pilots who flew in the contest
  def gather_contest_properties(pilot_contests)
    []
  end

end
