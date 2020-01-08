require 'test_helper'

module BasicContestData
  def setup_basic_contest_data(categories=nil)
    @contest = create :contest
    judge_pairs = create_list :judge, 3
    @pilots = create_list :member, 3
    @airplanes = create_list :airplane, 3
    flight_names = ['Known', 'Free', 'Unknown', 'Unknown II']
    @flights = []
    categories = [Category.first] unless categories
    categories.each do |cat|
      flight_names.each do |name|
        @flights << create(:flight,
          contest: @contest, name: name, category_id: cat.id)
      end
    end
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
