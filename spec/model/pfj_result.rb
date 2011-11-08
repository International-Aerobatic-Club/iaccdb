require 'spec_helper'

module Model
  describe PfjResult do
    it 'finds cached data' do
      scores = Factory.create(:adams_known_jim)
      pfj = Factory.create(:existing_pfj_result,
        :pilot_flight => scores.pilot_flight,
        :judge => scores.judge)
      rpfj = PfjResult.get_pfj(pfj.pilot_flight, pfj.judge)
      rpfj.computed_values.should == [2090, 1000, 1400, 1530, 1620, 2125, 2125,
        1400, 900, 1440, 1105, 510, 360, 760]
      rpfj.flight_value.should == 18365
      rpfj.id.should == pfj.id
    end
    it 'computes and caches figure and flight values' do
      pilot_flight = Factory.create(:denton_known)
      judge_team = Factory.create(:judge_klein)
      Factory.create(:denton_known_klein, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      pfj = PfjResult.get_pfj(pilot_flight, judge_team)
      pfj.pilot_flight_id.should == pilot_flight.id
      pfj.judge_id.should == judge_team.id
      pfj.computed_values.should == [1650, 800, 1120, 1445, 1530, 1875, 2125, 1190,
        810, 1280, 1105, 510, 300, 640]
      pfj.flight_value.should == 16380
    end
    it 'updates cached values when scores change' do
      pilot_flight = Factory.create(:denton_known)
      judge_team = Factory.create(:judge_klein)
      scores = Factory.create(:denton_known_klein, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      pfj = PfjResult.get_pfj(pilot_flight, judge_team)
      sleep 2
      va = scores.values
      va[3] = 100
      va[13] = 100
      scores.update_attribute(:values, va)
      scores.touch
      pfj = PfjResult.get_pfj(pilot_flight, judge_team)
      pfj.computed_values.should == [1650, 800, 1120, 1700, 1530, 1875, 2125, 1190,
        810, 1280, 1105, 510, 300, 800]
      pfj.flight_value.should == 16795
    end
  end
end
