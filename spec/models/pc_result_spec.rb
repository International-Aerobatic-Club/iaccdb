require 'spec_helper'

module Model
  describe PcResult do
    it 'finds cached data' do
      pc_result = Factory.create(:existing_pc_result)
      pc_result.category_value.should == 4992.14
      pc_result.category_rank.should == 1
    end
    context 'real_scores' do
      before(:all) do
        @contest = Factory.create(:nationals)
        @adams = Factory.create(:tom_adams)
        @denton = Factory.create(:bill_denton)
        judge_klein = Factory.create(:judge_klein)
        judge_jim = Factory.create(:judge_jim)
        judge_lynne = Factory.create(:judge_lynne)
        known_flight = Factory.create(:nationals_imdt_known,
          :contest => @contest)
        adams_flight = Factory.create(:adams_known,
          :flight => known_flight, :pilot => @adams)
        Factory.create(:adams_known_klein, 
          :pilot_flight => adams_flight,
          :judge => judge_klein)
        Factory.create(:adams_known_jim, 
          :pilot_flight => adams_flight,
          :judge => judge_jim)
        Factory.create(:adams_known_lynne, 
          :pilot_flight => adams_flight,
          :judge => judge_lynne)
        denton_flight = Factory.create(:denton_known,
          :flight => known_flight, :pilot => @denton)
        Factory.create(:denton_known_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        Factory.create(:denton_known_jim, 
          :pilot_flight => denton_flight,
          :judge => judge_jim)
        Factory.create(:denton_known_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        free_flight = Factory.create(:nationals_imdt_free,
          :contest => @contest)
        adams_flight = Factory.create(:adams_free,
          :flight => free_flight, :pilot => @adams)
        Factory.create(:adams_free_klein, 
          :pilot_flight => adams_flight,
          :judge => judge_klein)
        Factory.create(:adams_free_jim, 
          :pilot_flight => adams_flight,
          :judge => judge_jim)
        Factory.create(:adams_free_lynne, 
          :pilot_flight => adams_flight,
          :judge => judge_lynne)
        denton_flight = Factory.create(:denton_free,
          :flight => free_flight, :pilot => @denton)
        Factory.create(:denton_free_klein, 
          :pilot_flight => denton_flight,
          :judge => judge_klein)
        Factory.create(:denton_free_jim, 
          :pilot_flight => denton_flight,
          :judge => judge_jim)
        Factory.create(:denton_free_lynne, 
          :pilot_flight => denton_flight,
          :judge => judge_lynne)
        @c_results = @contest.results
      end
      it 'finds two pilots in category results' do
        c_result = @c_results.first(:conditions => {
          :category => 'Intermediate' })
        c_result.should_not be nil
        c_result.pc_results.size.should == 2
      end
      it 'computes category total for pilot' do
        c_result = @c_results.first(:conditions => {
          :category => 'Intermediate' })
        c_result.should_not be nil
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @adams })
        pc_result.should_not be nil
        pc_result.category_value.should == 0
        pc_result = c_result.pc_results.first(:conditions => {
          :pilot_id => @denton })
        pc_result.should_not be nil
        pc_result.category_value.should == 0
      end
      it 'computes category rank for pilot' do
        c_result = @c_results.first(:conditions => {
          :category => 'Intermediate' })
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
      it 'recomputes values when score changes'
      it 'recomputes values when sequence changes'
#      it 'updates cached values when scores change' do
#        scores = @pilot_flight.scores.where(:judge_id => judge_jim).first
#        va = scores.values
#        va[3] = 80
#        va[12] = 100
#        scores.save.should == true
#      contest = Contest.first(:conditions => {:start => '2011-09-25'})
#      contest.should_not be nil
#      flight = contest.flights.first(:conditions => {
#        :category => 'Intermediate', 
#        :name => 'Known'})
#      flight.should_not be nil
#      pilot = Member.find_by_iac_id(1999)
#      pilot.should_not be nil
#      @pilot_flight = PilotFlight.first(:conditions => {
#        :pilot_id => pilot, 
#        :flight_id => flight})
#      @pilot_flight.should_not be nil
#        pf = @pilot_flight.results
#        pfj = pf.for_judge(judge_jim)
#        pfj.computed_values.should == 
#          [2090, 1000, 1400, 1360, 1620, 2125, 2125,
#           1400, 900, 1440, 1105, 510, 400, 760]
#        pfj.flight_value.should == 18235
#        pf.flight_value.round(2).should == 1784.67
#      end
#      it 'updates cached values when sequence changes' do
#        @pilot_flight.sequence.k_values[13] = 12
#        @pilot_flight.sequence.save.should == true
#        contest = Contest.first(:conditions => {:start => '2011-09-25'})
#        contest.should_not be nil
#        flight = contest.flights.first(:conditions => {
#          :category => 'Intermediate', 
#          :name => 'Known'})
#        flight.should_not be nil
#        pilot = Member.find_by_iac_id(1999)
#        pilot.should_not be nil
#        @pilot_flight = PilotFlight.first(:conditions => {
#          :pilot_id => pilot, 
#          :flight_id => flight})
#        @pilot_flight.should_not be nil
#        pf = @pilot_flight.results
#        pf.flight_value.round(2).should == 1827
#      end
    end
    it 'behaves on empty sequence' 
#    do
#      @pf = Factory.create(:pilot_flight)
#      Factory.create(:score,
#        :pilot_flight => @pf,
#        :values => [60, 0, 0, 0, 0])
#      Factory.create(:score,
#        :pilot_flight => @pf,
#        :values => [-1, 0, 0, 0, 0])
#      @pf.results
#    end
  end
end
