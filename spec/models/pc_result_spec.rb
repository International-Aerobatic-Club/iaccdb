module Model
  describe PcResult do
    it 'finds cached data' do
      pc_result = Factory.create(:existing_pc_result)
      pc_result.category_value.should == 4992.14
      pc_result.category_rank.should == 1
    end
    context 'real_scores' do
      before(:each) do
        reset_db
        @contest = Factory.create(:nationals)
        @adams = Factory.create(:tom_adams)
        @denton = Factory.create(:bill_denton)
        judge_klein = Factory.create(:judge_klein)
        @judge_jim = Factory.create(:judge_jim)
        judge_lynne = Factory.create(:judge_lynne)
        known_flight = Factory.create(:nationals_imdt_known,
          :contest => @contest)
        @imdt_cat = known_flight.category
        @adams_flight = Factory.create(:adams_known,
          :flight => known_flight, :pilot => @adams)
        Factory.create(:adams_known_klein, 
          :pilot_flight => @adams_flight,
          :judge => judge_klein)
        Factory.create(:adams_known_jim, 
          :pilot_flight => @adams_flight,
          :judge => @judge_jim)
        Factory.create(:adams_known_lynne, 
          :pilot_flight => @adams_flight,
          :judge => judge_lynne)
        denton_flight = Factory.create(:denton_known,
          :flight => known_flight, :pilot => @denton)
        Factory.create(:denton_known_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        Factory.create(:denton_known_jim, 
          :pilot_flight => denton_flight,
          :judge => @judge_jim)
        Factory.create(:denton_known_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        free_flight = Factory.create(:nationals_imdt_free,
          :contest => @contest, :category => @imdt_cat)
        @adams_flight = Factory.create(:adams_free,
          :flight => free_flight, :pilot => @adams)
        Factory.create(:adams_free_klein, 
          :pilot_flight => @adams_flight,
          :judge => judge_klein)
        Factory.create(:adams_free_jim, 
          :pilot_flight => @adams_flight,
          :judge => @judge_jim)
        Factory.create(:adams_free_lynne, 
          :pilot_flight => @adams_flight,
          :judge => judge_lynne)
        denton_flight = Factory.create(:denton_free,
          :flight => free_flight, :pilot => @denton)
        Factory.create(:denton_free_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        Factory.create(:denton_free_jim, 
          :pilot_flight => denton_flight,
          :judge => @judge_jim)
        Factory.create(:denton_free_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        @c_results = @contest.results
      end

      it 'finds two pilots in category results' do
        c_result = @c_results.first(:conditions => {
          :category_id => @imdt_cat.id })
        c_result.should_not be nil
        c_result.pc_results.size.should == 2
      end

      it 'computes category total for pilot' do
        c_result = @c_results.first(:conditions => {
          :category_id => @imdt_cat.id })
        c_result.should_not be nil
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @adams })
        pc_result.should_not be nil
        pc_result.category_value.round(2).should == 3474.83
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @denton })
        pc_result.should_not be nil
        pc_result.category_value.round(2).should == 3459.33
      end

      it 'computes category rank for pilot' do
        c_result = @c_results.first(:conditions => {
          :category_id => @imdt_cat.id })
        c_result.should_not be nil
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @adams })
        pc_result.should_not be nil
        pc_result.category_rank.should == 1
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @denton })
        pc_result.should_not be nil
        pc_result.category_rank.should == 2
      end
    end
   
    it 'behaves on empty sequence' do
      @pf = Factory.create(:pilot_flight)
      Factory.create(:score,
        :pilot_flight => @pf,
        :values => [60, 0, 0, 0, 0])
      Factory.create(:score,
        :pilot_flight => @pf,
        :values => [-1, 0, 0, 0, 0])
      flight = @pf.flight
      contest = flight.contest
      contest.results
    end
  end
end
