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
    it 'behaves on empty sequence' do
        @pf = Factory.create(:pilot_flight)
        Factory.create(:score,
          :pilot_flight => @pf,
          :values => [60, 0, 0, 0, 0])
        Factory.create(:score,
          :pilot_flight => @pf,
          :values => [-1, 0, 0, 0, 0])
        @pf.results
    end
    context 'mixed grades, averages, and zeros' do
      before(:each) do
        seq = Factory.create(:sequence,
          :k_values => [2,2,2,2,2])
        @pf = Factory.create(:pilot_flight,
          :sequence => seq)
        @judges = []
        5.times { @judges << Factory.create(:judge) }
        Factory.create(:score,
          :pilot_flight => @pf,
          :judge => @judges[0],
          :values => [60, 0, 60, 0, 80])
        Factory.create(:score,
          :pilot_flight => @pf,
          :judge => @judges[1],
          :values => [-1, 0, 90, -1, -1])
        Factory.create(:score,
          :pilot_flight => @pf,
          :judge => @judges[2],
          :values => [80, 60, 0, 70, -1])
        Factory.create(:score,
          :pilot_flight => @pf,
          :judge => @judges[3],
          :values => [80, 70, 0, 80, 0])
        Factory.create(:score,
          :pilot_flight => @pf,
          :judge => @judges[4],
          :values => [60, 80, 0, 60, 0])
        #     f0, f1, f2, f3, f4
        # j0: 60, 70,  0, 70,  0 = 200
        # j1: 70, 70,  0, 70,  0 = 210
        # j2: 80, 60,  0, 70,  0 = 210
        # j3: 80, 70,  0, 80,  0 = 240
        # j4: 60, 80,  0, 60,  0 = 200
        #     70, 70,  0, 70,  0   210       
        @res = @pf.results
      end
      it 'converts average grade to the average' do
        @res.for_judge(@judges[1]).computed_values[0].should == 140
        @res.figure_results[0].should == 140
      end
      it 'converts minority zero to the average' do
        @res.figure_results[1].should == 140
      end
      it 'converts minority grade to zero' do
        @res.for_judge(@judges[0]).graded_values[2].should == 120
        @res.for_judge(@judges[1]).graded_values[2].should == 180
        @res.for_judge(@judges[0]).computed_values[2].should == 0
        @res.for_judge(@judges[1]).computed_values[2].should == 0
        @res.figure_results[2].should == 0
      end
      it 'converts minority zero and averages to the average' do
        @res.for_judge(@judges[0]).graded_values[3].should == 120
        @res.for_judge(@judges[1]).graded_values[3].should == 180
        @res.for_judge(@judges[0]).computed_values[3].should == 0
        @res.for_judge(@judges[1]).computed_values[3].should == 0
        @res.figure_results[3].should == 140
      end
      it 'converts minority grade and averages to zero' do
        @res.for_judge(@judges[0]).graded_values[4].should == 160
        @res.for_judge(@judges[1]).graded_values[4].should == 160
        @res.for_judge(@judges[2]).graded_values[4].should == 160
        @res.for_judge(@judges[0]).computed_values[4].should == 0
        @res.for_judge(@judges[1]).computed_values[4].should == 0
        @res.for_judge(@judges[2]).computed_values[4].should == 0
        @res.figure_results[4].should == 0
      end
      it 'computes flight values with resolved zeros and averages' do
        @res.for_judge(@judges[0]).flight_value.should == 400
        @res.for_judge(@judges[1]).flight_value.should == 420
        @res.for_judge(@judges[2]).flight_value.should == 420
        @res.for_judge(@judges[3]).flight_value.should == 480
        @res.for_judge(@judges[4]).flight_value.should == 400
        @res.flight_value.should == 420
      end
    end
  end
end
