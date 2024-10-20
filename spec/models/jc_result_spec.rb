module Model
  describe JcResult, :type => :model do
    context 'factory data' do
      before(:context) do
        @contest = create(:contest)
        @category = Category.where(category: 'Unlimited', aircat: 'P').first
        @flight = create(:flight,
          :contest => @contest,
          :category_id => @category.id)
        @judge_team = create(:judge)
        @jc_result = create(:jc_result,
          :contest => @contest,
          :category => @category,
          :judge => @judge_team.judge)
        @jf_result_1 = create(:jf_result,
          :flight => @flight,
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
        @jf_result_2 = create(:jf_result,
          :flight => @flight,
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
        @jc_result.compute_category_totals
      end
      it 'computes the Spearman rank coefficient' do
        expect(@jc_result.rho).to eq(94)
      end
      it 'computes the CIVA RI formula' do
        expect(@jc_result.ri).to eq(3.33)
      end
      it 'computes the Kendal tau' do
        expect(@jc_result.tau).to eq(62)
      end
      it 'computes the Gamma' do
        expect(@jc_result.gamma).to eq(62)
      end
      it 'computes the standard correlation coefficient' do
        expect(@jc_result.cc).to eq(78)
      end
      it 'computes the number of minority zeros' do
        expect(@jc_result.minority_zero_ct).to eq(4)
      end
      it 'computes the number of minority grades' do
        expect(@jc_result.minority_grade_ct).to eq(3)
      end
    end #context factory data
  end #JcResult
end #module
