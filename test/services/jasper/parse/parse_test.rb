require 'test_helper'
require 'xml'

module Jasper
  class ParseTest < ActiveSupport::TestCase
    setup do
      @jasper = Jasper::JasperParse.new
      parser = XML::Parser.file('spec/fixtures/jasper/jasperResultsFormat.xml')
      @jasper.do_parse(parser)
    end

    test 'captures a contest' do
      assert_equal('Test Contest US Candian Challenge', @jasper.contest_name)
      assert_equal('Olean', @jasper.contest_city)
      assert_equal('NY', @jasper.contest_state)
      assert_equal(126, @jasper.contest_chapter)
      assert_equal('NorthEast', @jasper.contest_region)
      assert_equal('Pat Barrett', @jasper.contest_director)
      cDate = @jasper.contest_date
      refute_nil(cDate)
      assert_equal(12, cDate.mon)
      assert_equal(23, cDate.day)
      assert_equal(2014, cDate.year)
      assert_equal('P', @jasper.aircat)
    end

    test 'gives category names' do
      assert_equal('Primary', @jasper.category_name(1))
      assert_equal('Sportsman', @jasper.category_name(2))
      assert_equal('Intermediate', @jasper.category_name(3))
      assert_equal('Advanced', @jasper.category_name(4))
      assert_equal('Unlimited', @jasper.category_name(5))
      assert_equal('Four Minute', @jasper.category_name(6))
    end

    test 'gives categories scored' do
      assert_equal([2,3,4,5,6], @jasper.categories_scored)
    end

    test 'gives flights scored' do
      assert_equal([1,2,3], @jasper.flights_scored(2))
    end

    test 'gives pilots scored' do
      assert_equal([1,2,3,4], @jasper.pilots_scored(2,2))
    end

    test 'gives judge teams for flight' do
      assert_equal([0,1,2,3], @jasper.judge_teams(2,2))
    end

    test 'gives chief judge' do
      assert_equal('2383', @jasper.chief_iac_number(3,2))
      assert_equal('Carole', @jasper.chief_first_name(3,2))
      assert_equal('Holyk', @jasper.chief_last_name(3,2))
    end

    test 'gives chief assistant' do
      assert_equal('28094', @jasper.chief_assist_iac_number(3,2))
      assert_equal('William', @jasper.chief_assist_first_name(3,2))
      assert_equal('Gordon', @jasper.chief_assist_last_name(3,2))
    end

    test 'gives pilot' do
      assert_equal('434969', @jasper.pilot_iac_number(2,3))
      assert_equal('Desmond', @jasper.pilot_first_name(2,3))
      assert_equal('Lightbody', @jasper.pilot_last_name(2,3))
      assert_equal('3/126/12', @jasper.pilot_chapter(2,3))
    end

    test 'strips patch from family name' do
      assert_equal('Thompson', @jasper.pilot_last_name(5,2))
    end

    test 'returns hors_concours for name with "(Patch)"' do
      assert(@jasper.pilot_is_hc(5,2))
      refute(@jasper.pilot_is_hc(2,3))
    end

    test 'gives airplane' do
      assert_equal('Sukoi', @jasper.airplane_make(4,1))
      assert_equal('29', @jasper.airplane_model(4,1))
      assert_equal('54CP', @jasper.airplane_reg(4,1))
    end

    test 'gives judge' do
      assert_equal('431885', @jasper.judge_iac_number(2,1,1))
      assert_equal('Sanford', @jasper.judge_first_name(2,1,1))
      assert_equal('Langworthy', @jasper.judge_last_name(2,1,1))
    end

    test 'gives judge assistant' do
      assert_equal('433272', @jasper.judge_assist_iac_number(2,1,1))
      assert_equal('Hella', @jasper.judge_assist_first_name(2,1,1))
      assert_equal('Comat', @jasper.judge_assist_last_name(2,1,1))
    end

    test 'gives penalty' do
      assert_equal(100, @jasper.penalty(3,3,1))
    end

    test 'gives grades' do
      assert_equal(
        '-1.0 8.5 8.5 9.0 8.5 9.0 9.0 9.0 8.5 9.5 ' +
        '0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0 8.5 ',
        @jasper.grades_for(2,1,1,1)
      )
    end

    test 'gives k values' do
      assert_equal('7 15 14 10 4 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 3 ',
        @jasper.k_values_for(1, 2, 1))
      assert_equal('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 1, 1))
      assert_equal('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 1, 2))
      assert_equal('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 2, 1))
      assert_equal('7 14 19 18 10 14 13 16 11 5 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 2, 2))
      assert_equal('17 7 4 14 15 16 14 17 10 10 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 3, 1))
      assert_equal('7 14 19 18 10 14 13 16 11 5 0 0 0 0 0 0 0 0 0 0 6 ',
        @jasper.k_values_for(2, 3, 2))
      assert_equal('9 10 15 14 11 19 10 13 17 16 11 17 14 14 0 0 0 0 0 0 8 ',
        @jasper.k_values_for(3, 2, 1))
      assert_equal('32 17 10 20 10 17 19 15 20 13 0 0 0 0 0 0 0 0 0 0 8 ',
        @jasper.k_values_for(3, 3, 1))
    end

    test 'finds collegiate competitors' do
      cps = @jasper.collegiate_pilots(2)
      assert_equal(3, cps.length)
      assert_includes(cps, '1')
      assert_includes(cps, '2')
      assert_includes(cps, '4')
    end

    test 'finds collegiate competitor colleges' do
      college = 'University of North Dakota'
      assert_equal(college, @jasper.pilot_college(3,1))
      assert_equal(college, @jasper.pilot_college(3,2))
      assert_equal(college, @jasper.pilot_college(3,3))
      assert_nil(@jasper.pilot_college(3,5))
    end
  end
end
