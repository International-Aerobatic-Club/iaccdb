require 'test_helper'
require_relative 'contest_data'

module Jasper
  class EmptyTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasper_post_331.xml')
      j2d = Jasper::JasperToDB.new
      j2d.process_contest(jasper)
      @contest = j2d.d_contest
    end

    test 'skips empty four minute program' do
      cat = Category.find_by(category: 'Four Minute')
      refute_nil(cat)
      flights = cat.flights.where(contest: @contest)
      assert_equal(0, flights.count)
    end

    test 'skips empty unlimited power program' do
      cat = Category.find_by(category: 'Unlimited', aircat: 'P')
      refute_nil(cat)
      flights = cat.flights.where(contest: @contest)
      assert_equal(0, flights.count)
    end

    test 'skips flight with pilots but no scores' do
      cat = Category.find_by(category: 'Advanced', aircat: 'P')
      refute_nil(cat)
      flights = cat.flights.where(contest: @contest)
      assert_equal(2, flights.count)
    end
  end
end
