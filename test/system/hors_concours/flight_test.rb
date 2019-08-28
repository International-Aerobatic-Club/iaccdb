require 'test_helper'
require 'shared/hors_concours_data'

class HorsConcours::FlightTest < ActionDispatch::IntegrationTest
  include HorsConcoursData

  setup do
    setup_hors_concours_data
    visit flight_path(@known_flight)
    hc_pilot_link = find(:xpath,
      "//table[@class='flight_results']//tr/td[@class='pilot']" +
      "/a[contains(@href, '/pilots/#{@hc_pilot.id}')]")
    @hc_pilot_cell = hc_pilot_link.find(:xpath, "./ancestor::td[1]")
    @hc_row = hc_pilot_link.find(:xpath, "./ancestor::tr[1]")
  end

  test 'show "(patch)" for pilots flying HC' do
    assert_match(/\(patch\)/, @hc_pilot_cell.text)
  end

  test 'show HC for ranking of pilot contest result' do
    hc_rank = @hc_row.find(:xpath, "./td[@class='overall_rank'][last()]")
    assert_equal('(HC)', hc_rank.text)
  end

  test 'show ranking of pilots after HC pilot as if HC pilot had not flown' do
    next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
    next_rank = next_row.find(:xpath, "./td[@class='overall_rank'][last()]")
    assert_equal('(4)', next_rank.text)
  end
end
