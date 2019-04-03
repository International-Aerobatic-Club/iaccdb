require 'test_helper'
require_relative 'contest_data'

module Jasper
  class NamesTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('JaSPer_post_IACCDB_301.xml')
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'judge family name' do
      judges = Member.where(iac_id: 435337).collect(&:family_name)
      assert_equal(2, judges.length)
      assert_includes(judges, '')
    end

    test 'judge given name' do
      judges = Member.where(iac_id: 433702).collect(&:given_name)
      assert_equal(1, judges.length)
      # we match a member on family name and IAC number
      # first name does not come into play
      # if we created a record, the value of first name that was
      # in play at creation will win.
    end

    test 'assistant given name' do
      assistants = Member.where(iac_id: 434137).collect(&:given_name)
      assert_equal(1, assistants.length)
    end

    test 'assistant family name' do
      assistants = Member.where(iac_id: 23687).collect(&:family_name)
      assert_equal(2, assistants.length)
      assert_includes(assistants, '')
    end

    test 'pilot given name' do
      pilots = Member.where(iac_id: 439211).collect(&:given_name)
      assert_equal(1, pilots.length)
    end

    test 'pilot family name' do
      pilots = Member.where(iac_id: 437520).collect(&:family_name)
      assert_equal(1, pilots.length)
      assert_includes(pilots, '')
    end

    test 'assistant with no last name and no IAC number' do
      judge = Member.where(iac_id: 430392).first
      teams = Judge.where(judge_id: judge.id)
      assistants = teams.collect(&:assist)
      family_names = assistants.collect(&:family_name)
      assert_includes(family_names, '')
    end

    test 'captures JaSPer identified HC competitor' do
      pilot = Member.where(iac_id: 24702).first
      assert_equal('Kevin', pilot.given_name)
      assert_equal('Campbell', pilot.family_name)
      pfs = PilotFlight.where(pilot_id: pilot.id)
      assert_equal(3, pfs.length)
      refute_includes(pfs.collect(&:hors_concours?), false)
    end

    test 'captures JaSPer identified real competitor' do
      pilot = Member.where(iac_id: 437050).first
      assert_equal('Mark', pilot.given_name)
      assert_equal('Budd', pilot.family_name)
      pfs = PilotFlight.where(pilot_id: pilot.id)
      assert_equal(3, pfs.length)
      refute_includes(pfs.collect(&:hors_concours?), true)
    end
  end
end
