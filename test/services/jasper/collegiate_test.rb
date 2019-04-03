require 'test_helper'
require_relative 'contest_data'

module Jasper
  class JasperToDbTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'captures collegiate teams' do
      teams = CollegiateResult.where(year: @contest.year)
      assert_equal(2, teams.count)
      team_names = teams.all.collect(&:name)
      assert_includes(team_names, 'University of North Dakota')
      assert_includes(team_names, 'United States Air Force Academy')
    end

    test 'captures collegiate participants' do
      usaf = CollegiateResult.where(year: @contest.year,
        name: 'United States Air Force Academy').first
      usaf_ids = usaf.members.collect(&:iac_id)
      assert_includes(usaf_ids, 430273)
      und = CollegiateResult.where(year: @contest.year,
        name: 'University of North Dakota').first
      und_ids = und.members.collect(&:iac_id)
      assert_includes(und_ids, 10467)
      assert_includes(und_ids, 28094)
      assert_equal(3, und_ids.count)
    end
  end
end
