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
      pf.flight_value.should == 1789
      pfn = pilot_flight.results
      pfn.updated_at.should == pf.updated_at
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
      sleep 2 # a two second delay to ensure time difference
      scores = pilot_flight.scores.where(:judge_id => judge_jim).first
      va = scores.values
      va[3] = 80
      va[12] = 100
      scores.save.should == true
      scores.touch
      pf = pilot_flight.results
      pfj = pilot_flight.pfj_results.where(:judge_id => judge_jim).first
      pfj.computed_values.should == 
        [2090, 1000, 1400, 1360, 1620, 2125, 2125,
         1400, 900, 1440, 1105, 510, 400, 760]
      pfj.flight_value.should == 18235
      pf.flight_value.round(2).should == 1784.67
    end
  end
end
