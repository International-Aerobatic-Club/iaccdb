module Model
  describe PcResult, :type => :model do
    it 'finds cached data' do
      pc_result = create(:existing_pc_result)
      expect(pc_result.category_value).to eq(4992.14)
      expect(pc_result.category_rank).to eq(1)
    end
    context 'real_scores' do
      before(:each) do
        @contest = create(:nationals)
        @adams = create(:tom_adams)
        @denton = create(:bill_denton)
        judge_klein = create(:judge_klein)
        @judge_jim = create(:judge_jim)
        judge_lynne = create(:judge_lynne)
        known_flight = create(:nationals_imdt_known,
          :contest => @contest)
        @imdt_cat = known_flight.category
        @adams_flight = create(:adams_known,
          :flight => known_flight, :pilot => @adams)
        create(:adams_known_klein, 
          :pilot_flight => @adams_flight,
          :judge => judge_klein)
        create(:adams_known_jim, 
          :pilot_flight => @adams_flight,
          :judge => @judge_jim)
        create(:adams_known_lynne, 
          :pilot_flight => @adams_flight,
          :judge => judge_lynne)
        denton_flight = create(:denton_known,
          :flight => known_flight, :pilot => @denton)
        create(:denton_known_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        create(:denton_known_jim, 
          :pilot_flight => denton_flight,
          :judge => @judge_jim)
        create(:denton_known_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        free_flight = create(:nationals_imdt_free,
          :contest => @contest, :category => @imdt_cat)
        @adams_flight = create(:adams_free,
          :flight => free_flight, :pilot => @adams)
        create(:adams_free_klein, 
          :pilot_flight => @adams_flight,
          :judge => judge_klein)
        create(:adams_free_jim, 
          :pilot_flight => @adams_flight,
          :judge => @judge_jim)
        create(:adams_free_lynne, 
          :pilot_flight => @adams_flight,
          :judge => judge_lynne)
        denton_flight = create(:denton_free,
          :flight => free_flight, :pilot => @denton)
        create(:denton_free_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        create(:denton_free_jim, 
          :pilot_flight => denton_flight,
          :judge => @judge_jim)
        create(:denton_free_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        @contest.results
      end

      it 'finds two pilots in category results' do
        pc_results = PcResult.where(
          :contest => @contest,
          :category => @imdt_cat)
        expect(pc_results).not_to be nil
        expect(pc_results.size).to eq(2)
      end

      it 'computes category total for pilot' do
        pc_results = PcResult.where(contest: @contest, category: @imdt_cat)
        expect(pc_results).not_to be nil
        pc_result = pc_results.where(:pilot_id => @adams).first
        expect(pc_result).not_to be nil
        expect(pc_result.category_value.round(2)).to eq(3474.83)
        pc_result = pc_results.where(:pilot_id => @denton).first
        expect(pc_result).not_to be nil
        expect(pc_result.category_value.round(2)).to eq(3459.33)
      end

      it 'computes category rank for pilot' do
        pc_results = PcResult.where(contest: @contest, category: @imdt_cat)
        expect(pc_results).not_to be nil
        pc_result = pc_results.where(:pilot_id => @adams).first
        expect(pc_result).not_to be nil
        expect(pc_result.category_rank).to eq(1)
        pc_result = pc_results.where(:pilot_id => @denton).first
        expect(pc_result).not_to be nil
        expect(pc_result.category_rank).to eq(2)
      end
    end

    it 'behaves on empty sequence' do
      @pf = create(:pilot_flight)
      create(:score,
        :pilot_flight => @pf,
        :values => [60, 0, 0, 0, 0])
      create(:score,
        :pilot_flight => @pf,
        :values => [-1, 0, 0, 0, 0])
      flight = @pf.flight
      contest = flight.contest
      contest.results
    end
  end
end
