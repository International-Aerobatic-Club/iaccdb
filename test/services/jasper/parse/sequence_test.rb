require 'test_helper'
require_relative '../contest_data'

module Jasper
  class ParseSequenceTest < ActiveSupport::TestCase
    include ContestData

    setup do
      @jasper = jasper_parse_from_test_data_file('jasperSequenceTest.xml')
      @known_ks = ['',
        '7 13 14 10 4 10 0 0 0 0 0 0 0 0 0 0 0 0 0 0 5',
        '10 17 10 14 4 10 10 17 13 14 0 0 0 0 0 0 0 0 0 0 10',
        '21 18 25 13 14 21 19 19 21 14 0 0 0 0 0 0 0 0 0 0 15',
        '40 16 36 40 42 32 33 19 26 0 0 0 0 0 0 0 0 0 0 0 25',
        '40 63 36 35 28 33 53 45 62 0 0 0 0 0 0 0 0 0 0 0 40',
        '40 40 40 40 40 40 40 40 40 40 0 0 0 0 0 0 0 0 0 0 0'
      ]
    end

    test 'always finds primary known' do
      assert_equal(@known_ks[1], @jasper.k_values_for(1, 1, 1).strip)
      assert_equal(@known_ks[1], @jasper.k_values_for(1, 1, 3).strip)
      assert_equal(@known_ks[1], @jasper.k_values_for(1, 2, 1).strip)
      assert_equal(@known_ks[1], @jasper.k_values_for(1, 3, 1).strip)
      assert_equal(@known_ks[1], @jasper.k_values_for(1, 4, 1).strip)
    end

    test 'always finds category knowns' do
      (2...6).each do |cat|
        assert_equal(@known_ks[cat], @jasper.k_values_for(cat, 1, 1).strip)
      end
    end

    test 'finds sportsman known when no pilot free' do
      assert_equal(@known_ks[2], @jasper.k_values_for(2, 2, 1).strip)
      assert_equal(@known_ks[2], @jasper.k_values_for(2, 3, 1).strip)
    end

    test 'finds sportsman pilot specified free' do
      free_ks = '23 14 21 12 18 16 23 15 11 25 24 21 27 29 21 0 0 0 0 0 25'
      assert_equal(free_ks, @jasper.k_values_for(2, 2, 2).strip)
      assert_equal(free_ks, @jasper.k_values_for(2, 3, 2).strip)
    end

    test 'finds sportsman pilot flight identified free' do
      free_ks = '14 21 12 23 18 16 23 15 11 25 24 21 27 29 21 0 0 0 0 0 25'
      assert_equal(free_ks, @jasper.k_values_for(2, 2, 3).strip)
      assert_equal(free_ks, @jasper.k_values_for(2, 3, 3).strip)
    end

    test 'finds advanced flight identified free' do
      jCat = 4; jFlt = 2; jPilot = 2;
      assert_equal(
        '11 14 21 12 18 16 23 15 23 25 24 21 27 29 21 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end

    test 'finds advanced flight unidentified free' do
      jCat = 4; jFlt = 2; jPilot = 3;
      assert_equal(
        '27 14 21 12 18 16 23 15 23 25 24 21 11 29 21 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end

    test 'finds advanced first unknown' do
      jCat = 4; jFlt = 3; jPilot = 2;
      assert_equal(
        '16 40 36 40 42 32 33 19 26 0 0 0 0 0 0 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end

    test 'finds advanced second unknown' do
      jCat = 4; jFlt = 4; jPilot = 2;
      assert_equal(
        '36 16 40 40 42 32 33 19 26 0 0 0 0 0 0 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end

    test 'finds advanced flight identified free unknown' do
      jCat = 4; jFlt = 3; jPilot = 1;
      assert_equal(
        '15 18 32 23 24 34 18 36 28 26 24 33 15 28 21 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end

    test 'finds advanced flight identified free unknown two' do
      jCat = 4; jFlt = 4; jPilot = 1;
      assert_equal(
        '14 32 12 28 27 25 26 34 31 29 18 22 25 31 33 0 0 0 0 0 25',
        @jasper.k_values_for(jCat, jFlt, jPilot).strip)
    end
  end
end
