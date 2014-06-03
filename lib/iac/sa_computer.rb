# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

# this class contains methods to compute results and rankings
# it follows the IAC straight average method
# revised 2014 to support soft and hard zero distinction
module IAC
class SaComputer

AVERAGE = -10
CONFERENCE_AVERAGE = -20
HARD_ZERO = -30

def initialize(pilot_flight)
  @pilot_flight = pilot_flight
end

# Compute result values for one pilot, one flight
# Accepts pilot_flight, creates or updates pfj_result, pf_result
# Does no computation if there are no sequence figure k values 
# Does no computation if pf_result entry is more recent than scores
# Returns the PfResult ActiveRecord instance
def computePilotFlight(has_soft_zero)
  @pf = @pilot_flight.pf_results.first || @pilot_flight.pf_results.build
  @seq = @pilot_flight.sequence
  @kays = @seq ? @seq.k_values : nil
  @kays = nil if @kays && @kays.length == 0
  @pf.flight_value = 0
  @pf.adj_flight_value = 0
  if @kays
    computeNonZeroValues(@pilot_flight.scores, has_soft_zero)
    resolveAverages
    storeGradedValues
    resolveZeros
    computeTotals
    storeResults
  end
  @pf
end

###
private
###

def computeNonZeroValues(pfScores, has_soft_zero)
  # @fjsx: scaled score for a figure is judge grade * k value
  #   Matrix of scaled scores indexed [figure][judge]
  # @judges: Judge for each index [j]
  # @zero_ct: count of hard zero scores for figure [f]
  # @score_ct: count of non-average scores for figure [f]
  #   Is count for which hard zeros must be a majority
  #   Includes grades, conference averages, and hard zeros
  # @grade_ct: count of grades for figure [f]
  #   Is number of grades given (including soft zeros) 
  #   for the average computation
  # @score_total: total of scaled scores for figure [f]
  @fjsx = []
  @kays.length.times { @fjsx << [] }
  @judges = []
  @zero_ct = Array.new(@kays.length, 0)
  @grade_ct = Array.new(@kays.length, 0)
  @score_ct = Array.new(@kays.length, 0)
  @score_total = Array.new(@kays.length, 0)
  pfScores.each do |score|
    @judges << score.judge
    score.values.each_with_index do |v, f|
      if f < @kays.length
        if 0 < v
          x = v * @kays[f]
          @score_total[f] += x
          @fjsx[f] << x
        else
          # map soft zero to hard zero if has_soft_zero is false
          v = HARD_ZERO if !has_soft_zero && v == 0
          @fjsx[f] << v
        end
        @zero_ct[f] += 1 if v == HARD_ZERO
        @score_ct[f] += 1 if v != AVERAGE
        @grade_ct[f] += 1 if 0 <= v
      else
        Rails.logger.error
          "More scores than K values in #{self}, judge #{score.judge}, flight #{score.pilot_flight},
          scores #{score}, kays #{@kays.join(', ')}"
      end
    end
  end
end

def resolveAverages
  @kays.length.times do |f|
    if @grade_ct[f] < @judges.length
      avg = average_score(f)
      @fjsx[f].length.times do |j|
        grade = @fjsx[f][j]
        if grade == CONFERENCE_AVERAGE || grade == AVERAGE
          @fjsx[f][j] = avg 
        end
      end
    end
  end
end

def storeGradedValues
  @judges.each_with_index do |judge, j|
    pfj = @pilot_flight.pfj_results.where(:judge_id => judge).first
    if !pfj 
      pfj = @pilot_flight.pfj_results.build(:judge => judge)
    end
    pfj.graded_values = make_judge_values(j)
    pfj.save
  end
end

def make_judge_values(j)
  jsa = []
  @kays.length.times do |f|
    jsa << @fjsx[f][j]
  end
  jsa
end

def resolveZeros
  @kays.length.times do |f|
    if 0 < @zero_ct[f]
      if (@score_ct[f] - @zero_ct[f] < @zero_ct[f])
        # majority zero
        @fjsx[f].length.times do |j|
          @fjsx[f][j] = 0
        end
      else
        # minority zero
        avg = average_score(f)
        @fjsx[f].length.times do |j|
          if @fjsx[f][j] == HARD_ZERO
            @fjsx[f][j] = avg 
          end
        end
      end
    end
  end
end

# rounds to the nearest 10th (rememeber scores are * 10)
def average_score(figure)
  if 0 < @grade_ct[figure] && 0 < @score_total[figure]
    (@score_total[figure].to_f / @grade_ct[figure]).round
  else
    0
  end
end

def computeTotals
  @j_totals = Array.new(@judges.length, 0)
  @f_totals = Array.new(@kays.length, 0)
  @judges.length.times do |j|
    @kays.length.times do |f|
      @j_totals[j] += @fjsx[f][j]
      @f_totals[f] += @fjsx[f][j]
    end
  end
end

def storeResults
  flight_total = 0.0
  @judges.each_with_index do |judge, j|
    pfj = @pilot_flight.pfj_results.where(:judge_id => judge).first
    if !pfj 
      pfj = @pilot_flight.pfj_results.build(:judge => judge)
    end
    pfj.computed_values = make_judge_values(j)
    pfj.flight_value = @j_totals[j]
    pfj.save
    flight_total += @j_totals[j]
  end
  @kays.length.times do |f|
    if (0 < @judges.length)
      @f_totals[f] = (@f_totals[f] / @judges.length.to_f).round.to_i
    else
      @f_totals[f] = 0
    end
  end
  @pf.figure_results = @f_totals
  if (0 < @judges.length)
    flight_avg = flight_total / (@judges.length * 10.0) # scores are stored * 10
  else
    flight_avg = 0
  end
  @pf.flight_value = flight_avg
  flight_avg -= @pilot_flight.penalty_total
  @pf.adj_flight_value = flight_avg < 0 ? 0 : flight_avg
  @pf.save
end

end #class
end #module
