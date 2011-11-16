
require 'spec_helper'

module Model
  describe RankComputer do
    before(:each) do
      seq = Factory.create(:sequence, :k_values => [2,2,2,2,2,2])
      @pilot_flights = []
      5.times { @pilot_flights << Factory.create(:pilot_flight, :sequence => seq)
      @judges = []
      5.times { @judges << Factory.create(:judge) }
      # pilot_flights[0]
      Factory.create(:score,
        :pilot_flight => @pilot_flights[0],
        :judge => @judges[0],
        :values => [60, 0, 60, 0, 80, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[0],
        :judge => @judges[1],
        :values => [-1, 0, 90, -1, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[0],
        :judge => @judges[2],
        :values => [80, 60, 0, 70, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[0],
        :judge => @judges[3],
        :values => [80, 70, 0, 80, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[0],
        :judge => @judges[4],
        :values => [60, 80, 0, 60, 0, 0])
      # pilot_flights[1]
      Factory.create(:score,
        :pilot_flight => @pilot_flights[1],
        :judge => @judges[0],
        :values => [60, 0, 60, 0, 80, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[1],
        :judge => @judges[1],
        :values => [-1, 0, 90, -1, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[1],
        :judge => @judges[2],
        :values => [80, 60, 0, 70, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[1],
        :judge => @judges[3],
        :values => [80, 70, 0, 80, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[1],
        :judge => @judges[4],
        :values => [60, 80, 0, 60, 0, 0])
      # pilot_flights[2]
      Factory.create(:score,
        :pilot_flight => @pilot_flights[2],
        :judge => @judges[0],
        :values => [60, 0, 60, 0, 80, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[2],
        :judge => @judges[1],
        :values => [-1, 0, 90, -1, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[2],
        :judge => @judges[2],
        :values => [80, 60, 0, 70, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[2],
        :judge => @judges[3],
        :values => [80, 70, 0, 80, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[2],
        :judge => @judges[4],
        :values => [60, 80, 0, 60, 0, 0])
      # pilot_flights[3]
      Factory.create(:score,
        :pilot_flight => @pilot_flights[3],
        :judge => @judges[0],
        :values => [60, 0, 60, 0, 80, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[3],
        :judge => @judges[1],
        :values => [-1, 0, 90, -1, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[3],
        :judge => @judges[2],
        :values => [80, 60, 0, 70, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[3],
        :judge => @judges[3],
        :values => [80, 70, 0, 80, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[3],
        :judge => @judges[4],
        :values => [60, 80, 0, 60, 0, 0])
      # pilot_flights[4]
      Factory.create(:score,
        :pilot_flight => @pilot_flights[4],
        :judge => @judges[0],
        :values => [60, 0, 60, 0, 80, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[4],
        :judge => @judges[1],
        :values => [-1, 0, 90, -1, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[4],
        :judge => @judges[2],
        :values => [80, 60, 0, 70, -1, -1])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[4],
        :judge => @judges[3],
        :values => [80, 70, 0, 80, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pilot_flights[4],
        :judge => @judges[4],
        :values => [60, 80, 0, 60, 0, 0])
    end
    it 'computes and caches figure and flight values' do
    end
  end
end
