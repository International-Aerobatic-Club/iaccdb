require 'test_helper'

module BasicContestData
  def setup_basic_contest_data
    @contest = create :contest
    judge_pairs = create_list :judge, 3
    @pilots = create_list :member, 3
    @airplanes = create_list :airplane, 3
    @flights = create_list :flight, 3, contest: @contest
    @flights.each do |flight|
      @pilots.each_with_index do |p, i|
        pf = create :pilot_flight, flight: flight, pilot: p,
          airplane: @airplanes[i]
        judge_pairs.each do |j|
          s = create :score, pilot_flight: pf, judge: j
        end
      end
    end
    @judges = judge_pairs.collect { |jp| jp.judge }
  end
end
