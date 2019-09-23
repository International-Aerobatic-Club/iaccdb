require 'test_helper'

module IAC
  class FindStarsTest < ActiveSupport::TestCase
    setup do
      # Contest year 2018, up to which year HZ grades are treated as zero
      @ctst = create(:contest, name: 'Test Find Stars', start: '2018-03-27')
      @cat = create(:category, category: 'Sportsman', name: 'Sportsman Power')
      seq = create(:sequence, figure_count: 4, k_values: [20, 4, 15, 9])
      flt = create(:flight, category_id: @cat.id, contest: @ctst)
      @pilot = create(:member)
      @pf = create(:pilot_flight, sequence: seq, flight: flt, pilot: @pilot)
      flt2 = create(:flight, category_id: @cat.id, contest: @ctst, name: 'Free')
      @pf2 = create(:pilot_flight, sequence: seq, flight: flt2, pilot: @pilot)
    end

    test 'counts hard zeros' do
      create(:score,
        values: [60, 65, Constants::HARD_ZERO, 70], pilot_flight: @pf)
      create(:score, values: [55, 80, 70, 60], pilot_flight: @pf)
      create(:score, values: [85, 95, 90, 90], pilot_flight: @pf)
      create(:score,
        values: [70, 100, Constants::HARD_ZERO, 80], pilot_flight: @pf2)
      create(:score, values: [75, 90, 80, 80], pilot_flight: @pf2)
      create(:score, values: [90, 90, 95, 90], pilot_flight: @pf2)
      pcres = create(:pc_result, contest: @ctst, category: @cat, pilot: @pilot)
      pcres.star_qualifying = true
      pcres.save
      FindStars.findStars(@ctst)
      pcres.reload
      refute(pcres.star_qualifying)
    end

    test 'finds star qualifying Sportsman flight' do
      create(:score, values: [60, 65, 55, 70], pilot_flight: @pf)
      create(:score, values: [55, 80, 70, 60], pilot_flight: @pf)
      create(:score, values: [85, 95, 90, 90], pilot_flight: @pf)
      create(:score, values: [70, 100, 55, 80], pilot_flight: @pf2)
      create(:score, values: [75, 90, 80, 80], pilot_flight: @pf2)
      create(:score, values: [90, 90, 95, 90], pilot_flight: @pf2)
      pcres = create(:pc_result, contest: @ctst, category: @cat, pilot: @pilot)
      FindStars.findStars(@ctst)
      pcres.reload
      assert(pcres.star_qualifying)
    end
  end
end
