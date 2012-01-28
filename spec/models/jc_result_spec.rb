require 'spec_helper'
require 'iac/mannyParse'
require 'iac/mannyToDB'

module Model
  describe JcResult do
    context 'factory data' do
      before(:all) do
        reset_db
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
          :sigma_d2 => 8,
          :sigma_p2 => 91,
          :sigma_j2 => 91,
          :sigma_pj => 87,
          :sigma_ri_delta => 0.1552617297,
          :con => 12,
          :dis => 3,
          :minority_zero_ct => 1,
          :minority_grade_ct => 2)
        @jf_result_2 = Factory.create(:jf_result,
          :f_result => @f_result,
          :jc_result => @jc_result,
          :judge => @judge_team,
          :pilot_count => 4,
          :sigma_d2 => 2,
          :sigma_p2 => 30,
          :sigma_j2 => 30,
          :sigma_pj => 29,
          :sigma_ri_delta => 0.0743063718,
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
        @jc_result.ri.should == 2.85
      end
      it 'computes the Kendal tau' do
        @jc_result.tau.should == 62
      end
      it 'computes the Gamma' do
        @jc_result.gamma.should == 62
      end
      it 'computes the standard correlation coefficient' do
        @jc_result.cc.should == 96
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
        manny = Manny::MannyParse.new
        IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
        m2d = IAC::MannyToDB.new
        m2d.process_contest(manny, true)
        contest = Contest.first
        contest.should_not be nil
        c_results = contest.results
        c_results.should_not be nil
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
