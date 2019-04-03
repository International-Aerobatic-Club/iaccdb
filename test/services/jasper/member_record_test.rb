require 'test_helper'
require_relative 'contest_data'

module Jasper
  class MemberRecordTest < ActiveSupport::TestCase
    include ContestData

    setup do
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      2.times do
        Member.create!(iac_id: 0, given_name: 'David', family_name: 'Crescenzo')
      end
      j2d = Jasper::JasperToDB.new
      @contest = j2d.process_contest(jasper)
    end

    test 'maps member name to a single member record' do
      boks = Member.where(given_name: 'Hans', family_name: 'Bok')
      assert_equal(1, boks.count)
    end

    test 'maps ambiguous member name to a single member record' do
      crecs = Member.where(given_name: 'David', family_name: 'Crescenzo')
      # the context set-up two existing records that duplicate this name.
      # the db mapper should create exactly one more.
      assert_equal(3, crecs.count)
    end

    test 'identifies pilots with (patch) on their names' do
      patch_pilots = Member.where(family_name: 'Thompson (patch)')
      assert_equal(0, patch_pilots.count)
      patch_pilots = Member.where(family_name: 'Thompson')
      assert_equal(1, patch_pilots.count)
      patch_flights = PilotFlight.where(pilot_id: patch_pilots.first.id)
      patch_flights.each do |pf|
        if pf.category.category == 'unlimited'
          assert(pf.hors_concours?)
        end
      end
    end
  end
end
