require 'test_helper'
require 'shared/hors_concours_data'

module Iac::HorsConcours
  class SyntheticCategoryTest < ActiveSupport::TestCase
    include HorsConcoursData

    setup do
      setup_hors_concours_flights
      last_seq = Category.pluck(:sequence).max
      synth_cat = create(:category, category: 'advanced', aircat: 'P',
        name: 'Advanced Team', seq: last_seq + 1, synthetic: true)
      @unknown_flights.each do |pf|
        flight = pf.flight
        unless flight.categories.exists?(synth_cat.id)
          flight.categories << synth_cat
          flight.save!
        end
      end
      @hc = Iac::HorsConcoursParticipants.new(@contest)
    end

    test 'does not treat synthetic as higher category' do
      @hc.mark_lower_category_participants_as_hc
      @unknown_flights.each do |flight|
        refute(flight.reload.hors_concours?)
        assert_equal(0, flight.hors_concours)
      end
    end
  end
end
