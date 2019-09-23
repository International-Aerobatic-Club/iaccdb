shared_context 'computed contest' do
  before do
    @year = Time.now.year
    @contest = create :contest, year: @year
    @ctf = 3
    @category = Category.first
    @flights = create_list :flight, @ctf, contest: @contest,
      category: @category.category, aircat: @category.aircat
    @flight = @flights.first
    @pilots = create_list :member, 3
    @airplanes = create_list :airplane, 3
    @judge_pairs = create_list :judge, 3
    @flights.each do |flight|
      @pilots.each_with_index do |p, i|
        pf = create :pilot_flight, flight: flight, pilot: p,
          airplane: @airplanes[i]
        @judge_pairs.each do |j|
          s = create :score, pilot_flight: pf, judge: j
        end
      end
    end
    @judges = @judge_pairs.collect { |jp| jp.judge }
    cc = ContestComputer.new(@contest)
    cc.compute_results
    @judge = @judge_pairs.first
    @jf_result = JfResult.where(flight: @flight, judge: @judge).first
    @pilot_flight = @flight.pilot_flights.first
  end
end
