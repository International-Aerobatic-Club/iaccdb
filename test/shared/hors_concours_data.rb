require 'test_helper'

module HorsConcoursData
  def setup_hors_concours_data
    judges = create_list(:judge, 3)

    @known_flight = create(:flight)
    @contest = @known_flight.contest
    known_sequence = create(:sequence)
    known_flights = create_list(:pilot_flight, 7, flight: @known_flight,
      sequence: known_sequence)
    known_flights.each_with_index do |pf, i|
      judges.each do |j|
        values = Array.new(known_sequence.figure_count, (10-i)*10)
        create(:score, pilot_flight: pf, judge: j, values: values)
      end
    end

    unknown_flight = create(:flight, name: 'Unknown',
      contest: @contest, category: @known_flight.category)
    unknown_sequence = create(:sequence)
    unknown_flights = {}
    known_flights.each_with_index do |kpf, i|
      pf = create(:pilot_flight,
        pilot: kpf.pilot, flight: unknown_flight, airplane: kpf.airplane,
        sequence: unknown_sequence)
      unknown_flights[kpf.pilot] = pf
      judges.each do |j|
        values = Array.new(unknown_sequence.figure_count, (10-i)*10)
        create(:score, pilot_flight: pf, judge: j, values: values)
      end
    end

    known_flights[3].hc_no_reason.save!
    @hc_pilot = known_flights[3].pilot
    unknown_flights[@hc_pilot].hc_no_reason.save!
    @non_hc_pilot = known_flights[1].pilot
    computer = ContestComputer.new(@contest)
    computer.compute_results
  end
end

