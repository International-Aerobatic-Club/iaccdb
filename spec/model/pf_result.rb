require 'spec_helper'

module Model
  describe PfResult do
    it 'finds cached data' do
      pf = Factory.create(:existing_pf_result)
      rpf = pf.pilot_flight.results
      rpf.flight_value.should == 1786.83
      rpf.adj_flight_value.should == 1756.83
      rpf.id.should == pf.id
    end
    it 'computes and caches figure and flight values' do
      pilot_flight = Factory.create(:adams_known)
      judge_team = Factory.create(:judge_klein)
      Factory.create(:adams_known_klein, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      judge_jim = Factory.create(:judge_jim)
      Factory.create(:adams_known_jim, 
        :pilot_flight => pilot_flight,
        :judge => judge_jim)
      judge_team = Factory.create(:judge_lynne)
      Factory.create(:adams_known_lynne, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      pf = pilot_flight.results
      pfj = pilot_flight.pfj_results.where(:judge_id => judge_jim).first
      pfj.computed_values.should == 
        [2090, 1000, 1400, 1530, 1620, 2125, 2125,
         1400, 900, 1440, 1105, 510, 360, 760]
      pfj.flight_value.should == 18365
      pf = pilot_flight.results
      pf.flight_value.should == 1789
    end
    it 'updates cached values when scores change' do
      pilot_flight = Factory.create(:adams_known)
      judge_team = Factory.create(:judge_klein)
      Factory.create(:adams_known_klein, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      judge_jim = Factory.create(:judge_jim)
      Factory.create(:adams_known_jim, 
        :pilot_flight => pilot_flight,
        :judge => judge_jim)
      judge_team = Factory.create(:judge_lynne)
      Factory.create(:adams_known_lynne, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      pf = pilot_flight.results
      sleep 2
      scores = Score.where(:pilot_flight_id => pilot_flight, 
        :judge_id => judge_team).first
      va = scores.values
      va[3] = 80
      va[12] = 100
      scores.update_attribute(:values, va)
      scores.touch
      pf = pilot_flight.results
      pfj = pilot_flight.pfj_results.where(:judge_id => judge_jim).first
      pfj.computed_values.should == 
        [2090, 1000, 1120, 1530, 1620, 2125, 2125,
         1400, 900, 1440, 1105, 600, 360, 760]
      pfj.flight_value.should == 18175
      pf = pilot_flight.results
      pf.flight_value.should == 1782.67
    end
  end
end
