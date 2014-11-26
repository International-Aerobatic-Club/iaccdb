module Model
  describe JcResult do
    context 'factory data' do
      before(:all) do
        @contest = Factory.create(:contest)
        @c_result = Factory.create(:c_result,
          :contest => @contest)
        @flight = Factory.create(:flight,
          :contest => @contest)
        @judge_team = Factory.create(:judge)
        @jc_result = Factory.create(:jc_result, 
          :c_result => @c_result, 
          :judge => @judge_team.judge)
        @f_result = Factory.create(:f_result, 
          :flight => @flight, 
          :c_result => @c_result)
        @jf_result_1 = Factory.create(:jf_result,
          :f_result => @f_result,
          :jc_result => @jc_result,
          :judge => @judge_team,
          :pilot_count => 6,
          :pair_count => 15,
          :ftsdxdy => 54,
          :ftsdx2 => 70,
          :ftsdy2 => 70,
          :sigma_d2 => 8,
          :sigma_ri_delta => 0.1552617297,
          :ri_total => 3.7421482217,
          :flight_count => 1,
          :con => 12,
          :dis => 3,
          :minority_zero_ct => 1,
          :minority_grade_ct => 2)
        @jf_result_2 = Factory.create(:jf_result,
          :f_result => @f_result,
          :jc_result => @jc_result,
          :judge => @judge_team,
          :pilot_count => 4,
          :pair_count => 6,
          :ftsdxdy => 16,
          :ftsdx2 => 20,
          :ftsdy2 => 20,
          :sigma_d2 => 2,
          :sigma_ri_delta => 0.0743063718,
          :ri_total => 2.9277530262,
          :flight_count => 1,
          :con => 5,
          :dis => 1,
          :minority_zero_ct => 3,
          :minority_grade_ct => 1)
        @jc_result.compute_category_totals(@flight.f_results)
      end
      it 'computes the Spearman rank coefficient' do
        @jc_result.rho.should == 94
      end
      it 'computes the CIVA RI formula' do
        @jc_result.ri.should == 3.33
      end
      it 'computes the Kendal tau' do
        @jc_result.tau.should == 62
      end
      it 'computes the Gamma' do
        @jc_result.gamma.should == 62
      end
      it 'computes the standard correlation coefficient' do
        @jc_result.cc.should == 78
      end
      it 'computes the number of minority zeros' do
        @jc_result.minority_zero_ct.should == 4
      end
      it 'computes the number of minority grades' do
        @jc_result.minority_grade_ct.should == 3
      end
    end #context factory data
    context 'parsed data' do
      it 'computes category level judge results' do
        manny = Manny::Parse.new
        IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
        m2d = Manny::MannyToDB.new
        m2d.process_contest(manny, true)
        contest = Contest.first
        contest.should_not be nil
        contest.flights.should_not be_nil
        contest.flights.count.should eq 12
        c_results = contest.results
        c_results.should_not be nil
        c_results.count.should eq 4
        c_result = c_results.first
        c_result.should_not be nil
        c_result.f_results.should_not be nil
        f_result = c_result.f_results.first
        f_result.should_not be nil
        flight = f_result.flight
        flight.should_not be nil 
      end
    end
  end #JcResult
end #module
