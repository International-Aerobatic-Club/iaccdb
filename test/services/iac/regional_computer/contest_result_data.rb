require 'test_helper'

module IAC
  module ContestResultData
    attr_accessor :year, :region
    attr_reader :category,
      :c_green, :c_kjc, :c_blue,
      :pilot_taylor, :pilot_schreck, :pilot_smith

    def setup_contest_results
      @year = 2015
      @region = 'NorthEast'
      start = Time.mktime(@year)
      c_ntnls = create(:contest, start: start,
        region: 'National',
        name: 'U.S. National Aerobatic Championships')
      c_olean = create(:contest, start: start,
        region: @region,
        name: 'Bill Thomas US - Canada Aerobatic Challenge')
      c_east = create(:contest, start: start,
        region: @region,
        name: 'East Coast Aerobatic Contest')
      @c_green = create(:contest, start: start,
        region: @region,
        name: 'Green Mountain Aerobatic Contest')
      c_carolina = create(:contest, start: start,
        region: @region,
        name: 'Carolina Boogie')
      @c_kjc = create(:contest, start: start,
        region: @region,
        name: 'Kathy Jaffe Challenge')
      @c_blue = create(:contest, start: start,
        region: @region,
        name: 'Blue Ridge Hammerfest')
      @category = Category.find_for_cat_aircat('sportsman', 'P')

      @pilot_taylor = Member.create(
        iac_id: 2112, given_name: 'David',
        family_name: 'Taylor')
      PcResult.create(pilot: @pilot_taylor,
        category: @category,
        contest: @c_green,
        category_value: 2123.36, total_possible: 2720)
      PcResult.create(pilot: @pilot_taylor,
        category: @category,
        contest: c_olean,
        category_value: 3384.33, total_possible: 4080)
      PcResult.create(pilot: @pilot_taylor,
        category: @category,
        contest: c_east,
        category_value: 2288.00, total_possible: 2720)
      PcResult.create(pilot: @pilot_taylor,
        category: @category,
        contest: c_ntnls,
        category_value: 3360.26, total_possible: 4080)

      @pilot_schreck = Member.create(
        iac_id: 21298,
        given_name: 'Ron', 
        family_name: 'Schreck')
      PcResult.create!(pilot: @pilot_schreck,
        category: @category,
        contest: c_carolina,
        category_value: 3463.17, total_possible: 4080)
      PcResult.create(pilot: @pilot_schreck,
        category: @category,
        contest: @c_kjc,
        category_value: 2865.38, total_possible: 4080)
      PcResult.create(pilot: @pilot_schreck,
        category: @category,
        contest: c_east,
        category_value: 2237.83, total_possible: 2720)
      PcResult.create(pilot: @pilot_schreck,
        category: @category,
        contest: @c_blue,
        category_value: 3322.33, total_possible: 4080)

      @pilot_smith = Member.create(
        iac_id: 21238,
        given_name: 'Ron', 
        family_name: 'Smith')
      PcResult.create(pilot: @pilot_smith,
        category: @category,
        contest: @c_green,
        category_value: 1953.10, total_possible: 2720)
      PcResult.create(pilot: @pilot_smith,
        category: @category,
        contest: @c_kjc,
        category_value: 2829.13, total_possible: 4080)
    end
  end
end
