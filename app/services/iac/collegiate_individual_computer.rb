# Computes Collegiate Individual series results and leaves them in the database
# This computation works in phases.
# First, gather collegiate pilots who have participated in three or more contests
# Second, compute best combination of three results for each pilot
# Third, rank competitors based on their results and eligibility.
class Iac::CollegiateIndividualComputer

  attr_reader :year

  def initialize (year)
    @year = year
  end

  # Compute the year's Collegiate Individual result
  def recompute
    @collegiates = collegiates_for_pilots
    @collegiates.each { |student| student.compute_result }
    Iac::RankComputer.compute_result_rankings(@collegiates)
  end

  ###
  private
  ###

  def collegiates_for_pilots

    # Build a query to retrieve all collegiate pilots who completed in the specified year
    pilots = Member.joins(result_members: :result, pc_results: [:contest, :category])
                   # Filter for contests within the specified year
                   .where('YEAR(contests.start) = ?', year)
                   # Filter for collegiate results from the current year
                   .where(result_members: { results: { type: 'CollegiateResult', year: year  } } )
                   # Eliminate any duplicates
                   .distinct

    collegiates = pilots.map{ |pilot| engage_student_for_pilot(pilot) }
    trim_collegiates(collegiates)
    collegiates

  end

  # finds or creates student record for pilot
  # links pc_results for year
  # returns the student record
  def engage_student_for_pilot(pilot)
    student = CollegiateIndividualResult.where(pilot_id: pilot.id,
      year: year).first_or_create
    to_be_results = Iac::CollegiateComputer.pilot_results(pilot, year)
    student.update_results(to_be_results)
  end

  # remove any collegiates for year not in the list
  def trim_collegiates(to_be_collegiates)
    existing_collegiates = CollegiateIndividualResult.where(year: year).all
    to_remove = existing_collegiates - to_be_collegiates
    to_remove.each { |student| student.destroy }
  end

end
