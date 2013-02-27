require 'spec_helper'
require 'iac/jasper_parse'
require 'xml'

module JaSPer
  describe JaSPerParse do
    before(:all) do
      @jasper = JaSPer::JaSPerParse.new
      parser = XML::Parser.file('spec/jasper/jasperResultsFormat.xml')
      @jasper.do_parse(parser)
    end
    it 'captures a contest' do
      @jasper.contest_name.should == 'US Candian Challenge'
      @jasper.contest_city.should == 'Olean'
      @jasper.contest_state.should == 'NY'
      @jasper.contest_chapter.should == '126'
      @jasper.contest_region.should == 'NorthEast'
      @jasper.contest_director.should == 'Pat Barrett'
      cDate = @jasper.contest_date
      cDate.should_not be_nil
      cDate.mon.should == 6
      cDate.day.should == 23
      cDate.year.should == 2012
      @jasper.aircat.should == 'P'
    end
    it 'gives category names' do
      @jasper.category_name(1).should == 'Primary'
      @jasper.category_name(2).should == 'Sportsman'
      @jasper.category_name(3).should == 'Intermediate'
      @jasper.category_name(4).should == 'Advanced'
      @jasper.category_name(5).should == 'Unlimited'
      @jasper.category_name(6).should == 'Four Minute'
    end
    it 'gives categories scored' do
      @jasper.categories_scored.should == [2,3,4,5]
    end
    it 'gives flights scored' do
      @jasper.flights_scored(2).should == [1,2,3]
    end
    it 'gives pilots scored' do
      @jasper.pilots_scored(2,2).should == [1,2,3,4]
    end
    it 'gives judge teams for flight' do
      @jasper.judge_teams(2,2).should == [0,1,2,3]
    end
    it 'gives chief judge' do
      @jasper.chief_iac_number(3,2).should == '2383'
      @jasper.chief_first_name(3,2).should == 'Carole'
      @jasper.chief_last_name(3,2).should == 'Holyk'
    end
    it 'gives chief assistant' do
      @jasper.chief_assist_iac_number(3,2).should == '28094'
      @jasper.chief_assist_first_name(3,2).should == 'William'
      @jasper.chief_assist_last_name(3,2).should == 'Gordon'
    end
    it 'gives pilot' do
      @jasper.pilot_iac_number(2,3).should == '434969'
      @jasper.pilot_first_name(2,3).should == 'Desmond'
      @jasper.pilot_last_name(2,3).should == 'Lightbody'
      @jasper.pilot_chapter(2,3).should == '3'
    end
    it 'gives judge' do
      @jasper.judge_iac_number(2,1,1).should == '431885'
      @jasper.judge_first_name(2,1,1).should == 'Sanford'
      @jasper.judge_last_name(2,1,1).should == 'Langworthy'
    end
    it 'gives judge assistant' do
      @jasper.judge_assist_iac_number(2,1,1).should == '433272'
      @jasper.judge_assist_first_name(2,1,1).should == 'Hella'
      @jasper.judge_assist_last_name(2,1,1).should == 'Comat'
    end
    it 'gives penalty' do
      @jasper.penalty(3,3,1).should == 100
    end
    it 'gives grades' do
      @jasper.grades_for(2,1,1,1).should == '-1.0 8.5 8.5 9.0 8.5 9.0 9.0 9.0 8.5 9.5 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 8.5 ' 
    end
    it 'gives k values' do
      @jasper.k_values_for(1, 2, 1).should == '7 15 14 10 4 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 '
      @jasper.k_values_for(2, 1, 1).should == '17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 '
      @jasper.k_values_for(2, 2, 1).should == '6 15 21 16 8 16 15 14 12 4 0 0 0 0 0 0 0 0 0 0 6 '
      @jasper.k_values_for(2, 3, 1).should == '6 15 21 16 8 16 15 14 12 4 0 0 0 0 0 0 0 0 0 0 6 '
      @jasper.k_values_for(3, 2, 1).should == '9 10 15 14 11 19 10 13 17 16 11 17 14 14 0 0 0 0 0 0 8 '
      @jasper.k_values_for(3, 3, 1).should == '32 17 10 20 10 17 19 15 20 13 0 0 0 0 0 0 0 0 0 0 8 '
    end
  end
end
