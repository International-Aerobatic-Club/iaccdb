require 'test_helper'
require 'shared/hors_concours_data'

class HorsConcours::CategoryTest < ActionDispatch::IntegrationTest
  include HorsConcoursData

  setup do
    setup_hors_concours_data
    visit contest_path(@contest)
    hc_pilot_link = find(:xpath,
      "//table[@class='pilot_results']//tr/td[@class='pilot'][1]" +
      "/a[contains(@href, '/pilots/#{@hc_pilot.id}')]")
    @hc_pilot_cell = hc_pilot_link.find(:xpath, "./ancestor::td[1]")
    @hc_row = hc_pilot_link.find(:xpath, "./ancestor::tr[1]")
  end

  test 'show "(patch)" for pilots flying HC' do
    assert_match(/\(patch\)/, @hc_pilot_cell.text)
  end

  test 'show HC for ranking of pilot contest result' do
    hc_rank = @hc_row.find(:xpath, "./td[@class='rank'][last()]")
    assert_equal('(HC)', hc_rank.text)
  end

  test 'show contest ranking of pilots after HC pilot' +
     ' as if HC pilot had not flown' do
    next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
    next_rank = next_row.find(:xpath, "./td[@class='rank'][last()]")
    assert_equal('(4)', next_rank.text)
  end

  test 'show HC in ranking of individual flights' do
    known_rank = @hc_row.find(:xpath, "./td[@class='rank'][1]")
    assert_equal('(HC)', known_rank.text)
    free_rank = @hc_row.find(:xpath, "./td[@class='rank'][2]")
    assert_equal('(HC)', free_rank.text)
  end

  test 'show flight ranking of pilots after HC pilot' +
     ' as if HC pilot had not flown' do
    next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
    known_rank = next_row.find(:xpath, "./td[@class='rank'][1]")
    assert_equal('(4)', known_rank.text)
    free_rank = next_row.find(:xpath, "./td[@class='rank'][2]")
    assert_equal('(4)', free_rank.text)
  end
end
