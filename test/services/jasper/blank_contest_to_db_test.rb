require 'test_helper'
require_relative 'contest_data'

module Jasper
  class BlankContestToDbTest < ActiveSupport::TestCase
    include ContestData

    setup do
      @jasper = parse_contest_data(blank_empty_contest)
      @j2db = Jasper::JasperToDB.new
    end

    test 'extract params' do
      now = Date.today
      Timecop.freeze(now) do
        params = @j2db.extract_contest_params_hash(@jasper)
        assert_equal('missing contest name', params['name'])
        assert_equal(Date.today, params['start'])
        assert_empty(params['region'])
        assert_empty(params['director'])
        assert_empty(params['city'])
        assert_empty(params['state'])
        assert_empty(params['chapter'])
      end
    end

    test 'creates new contest' do
      contest = @j2db.process_contest(@jasper)
      refute_nil(contest)
      refute_nil(contest.id)
      assert_equal(1, Contest.count)
    end
  end
end
