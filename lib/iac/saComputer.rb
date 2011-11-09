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
  @judges = []
  @fjsx = []
  @kays.length.times { @fjsx << [] }
  @zero_ct = Array.new(@kays.length, 0)
  @score_ct = Array.new(@kays.length, 0)
  @score_total = Array.new(@kays.length, 0)
  @pfScores.each do |score|
    @judges << score.judge
    score.values.each_with_index do |v, i|
      @zero_ct[i] += 1 if v == 0
      if 0 < v
        x = v * @kays[i]
        @score_ct[i] += 1
        @score_total[i] += x
        @fjsx[i] << x
      else
        @fjsx[i] << v
      end
    end
  end
end

def resolveAverages
  (0 ... @kays.length).each do |f|
    if @score_ct[f] + @zero_ct[f] < @judges.length
      avg = average_score(f)
      # rounds to the nearest 10th (rememeber scores are * 10)
      @fjsx[f].each_with_index do |j|
        @fjsx[f][j] = avg if @fjsx[f][j] < 0
      end
    end
  end
end

def storeExtendedScores
  @judges.each_with_index do |judge, j|
    jsa = []
    (0 ... @kays.length).each do |f|
      jsa << @fjsx[f][j]
    end
    pfj = @pilot_flight.pfj_results.where(:judge_id => judge).first
    if !pfj 
      pfj = @pilot_flight.pfj_results.build(:judge => judge)
    end
    pfj.computed_values = jsa
    pfj.save
  end
end

def resolveZeros
  (0 ... @kays.length).each do |f|
    if 0 < @zero_ct[f]
      if (0 < (@score_ct[f] - 2 * @zero_ct[f]))
        # minority zero
        avg = average_score(f)
        @fjsx[f].each_with_index do |j|
          @fjsx[f][j] = avg if @fjsx[f][j] == 0
        end
      else
        # majority zero
        @fjsx[f].each_with_index do |j|
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
  @totals = []
  (0 ... @judges.length).each do |j|
    total = 0
    (0 ... @kays.length).each do |f|
      total += @fjsx[f][j]
    end
    @totals << total
  end
end

def storeResults
  flight_total = 0.0
  @judges.each_with_index do |judge, j|
    pfj = @pilot_flight.pfj_results.where(:judge_id => judge).first
    if !pfj 
      pfj = @pilot_flight.pfj_results.build(:judge => judge)
    end
    pfj.flight_value = @totals[j]
    pfj.save
    flight_total += @totals[j]
  end
  flight_avg = flight_total / (@judges.length * 10.0) # scores are stored * 10
  @pf.flight_value = flight_avg
  flight_avg -= @pilot_flight.penalty_total
  @pf.adj_flight_value = flight_avg
  @pf.save
end

end #class
end #module
