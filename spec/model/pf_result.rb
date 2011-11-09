require 'spec_helper'

module Model
  describe PfjResult do
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
      rpfj = pilot_flight.results_by_judge
      pfj = rpfj[judge_jim]
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
      judge_team = Factory.create(:judge_jim)
      Factory.create(:adams_known_jim, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      judge_team = Factory.create(:judge_lynne)
      Factory.create(:adams_known_lynne, 
        :pilot_flight => pilot_flight,
        :judge => judge_team)
      pf = pilot_flight.results
      sleep 2
      scores = Score.where(:pilot_flight_id => pilot_flight, 
        :judge_id => judge_team).first
      va = scores.values
      va[3] = 100
      va[12] = 100
      scores.update_attribute(:values, va)
      scores.touch
      rpfj = pilot_flight.results_by_judge
      pfj = rpfj[judge_jim]
      pfj.computed_values.should == 
        [2090, 1000, 1400, 1530, 1620, 2125, 2125,
         1400, 900, 1440, 1105, 510, 360, 760]
      pfj.flight_value.should == 18365
      pf = pilot_flight.results
      pf.flight_value.should == 1796
    end
  end
end
