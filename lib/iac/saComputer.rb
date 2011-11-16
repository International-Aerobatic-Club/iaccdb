# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

# this class contains methods to compute results and rankings
# it follows the IAC straight average method
module IAC
class SAComputer

def initialize(pilot_flight)
  @pilot_flight = pilot_flight
end

# Compute result values for one pilot, one flight
# Accepts pilot_flight, creates or updates pfj_result, pf_result
# Does no computation if there are no sequence figure k values 
# Does no computation if pf_result entry is more recent than scores
# Returns the PfResult ActiveRecord instance
def computePilotFlight
  @pf = @pilot_flight.pf_results.first
  if !@pf then @pf = @pilot_flight.pf_results.build end
  @seq = @pilot_flight.sequence
  @kays = @seq ? @seq.k_values : nil
  @kays = nil if @kays && @kays.length == 0
  if @pf.new_record?
    compute = true
  else
    compute = false
    @pfScores = @pilot_flight.scores
    @pfScores.each do |score|
      compute ||= @pf.updated_at < score.updated_at
    end
  end
  if compute
    @pf.flight_value = 0
    @pf.adj_flight_value = 0
    if @kays
      @pfScores ||= @pilot_flight.scores
      computeNonZeroValues
      resolveAverages
      storeExtendedScores
      resolveZeros
      computeTotals
      storeResults
    end
  end
  @pf
end

###
private
###

def computeNonZeroValues
  # scaled score for a figure is judge grade * k value
  # Matrix of scaled scores indexed [figure][judge]
  @fjsx = []
  @kays.length.times { @fjsx << [] }
  # Judges for each index [j]
  @judges = []
  # count of zero scores for figure [f]
  @zero_ct = Array.new(@kays.length, 0)
  # count of non-zero scores for figure [f]
  @score_ct = Array.new(@kays.length, 0)
  # total of scaled scores for figure [f]
  @score_total = Array.new(@kays.length, 0)
  @pfScores.each do |score|
    @judges << score.judge
    score.values.each_with_index do |v, f|
      if f < @kays.length
        @zero_ct[f] += 1 if v == 0
        if 0 < v
          x = v * @kays[f]
          @score_ct[f] += 1
          @score_total[f] += x
          @fjsx[f] << x
        else
          @fjsx[f] << v
        end
      else
        throw ArgumentError, 
          "More scores than K values in #{self}, judge #{score.judge}"
      end
    end
  end
end

def resolveAverages
  @kays.length.times do |f|
    if @score_ct[f] + @zero_ct[f] < @judges.length
      avg = average_score(f)
      @fjsx[f].length.times do |j|
        @fjsx[f][j] = avg if @fjsx[f][j] < 0
      end
    end
  end
end

def storeExtendedScores
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
      if (0 < (@score_ct[f] - 2 * @zero_ct[f]))
        # minority zero
        avg = average_score(f)
        @fjsx[f].length.times do |j|
          @fjsx[f][j] = avg if @fjsx[f][j] == 0
        end
      else
        # majority zero
        @fjsx[f].length.times do |j|
          @fjsx[f][j] = 0
        end
      end
    end
  end
end

# rounds to the nearest 10th (rememeber scores are * 10)
def average_score(figure)
  (@score_total[figure].to_f / @score_ct[figure]).round
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
    @f_totals[f] /= @judges.length.to_f
  end
  @pf.figure_results = @f_totals
  flight_avg = flight_total / (@judges.length * 10.0) # scores are stored * 10
  @pf.flight_value = flight_avg
  flight_avg -= @pilot_flight.penalty_total
  @pf.adj_flight_value = flight_avg
  @pf.save
end

end #class
end #module
