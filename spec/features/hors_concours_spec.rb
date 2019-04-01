require 'rails_helper'
require 'shared/hors_concours_context'

RSpec.feature "HorsConcours", :type => :feature do
  include_context 'hors_concours flight'
  context 'category results' do
    before :each do
      visit contest_path(@contest)
      hc_pilot_link = find(:xpath,
        "//table[@class='pilot_results']//tr/td[@class='pilot'][1]" +
        "/a[contains(@href, '/pilots/#{@hc_pilot.id}')]")
      @hc_pilot_cell = hc_pilot_link.find(:xpath, "./ancestor::td[1]")
      @hc_row = hc_pilot_link.find(:xpath, "./ancestor::tr[1]")
    end
    it 'show "(patch)" for pilots flying HC' do
      expect(@hc_pilot_cell.text).to match /\(patch\)/
    end
    it 'show HC for ranking of pilot contest result' +
       ' where pc_result has hors_concours' do
      hc_rank = @hc_row.find(:xpath, "./td[@class='rank'][last()]")
      expect(hc_rank.text).to eq "(HC)"
    end
    it 'show contest ranking of pilots after HC pilot' +
       ' as if HC pilot had not flown' do
      next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
      next_rank = next_row.find(:xpath, "./td[@class='rank'][last()]")
      expect(next_rank.text).to eq "(4)"
    end
    it 'show HC in ranking of individual flights' +
       ' where pf_result has hors_concours' do
      known_rank = @hc_row.find(:xpath, "./td[@class='rank'][1]")
      expect(known_rank.text).to eq "(HC)"
      free_rank = @hc_row.find(:xpath, "./td[@class='rank'][2]")
      expect(free_rank.text).to eq "(HC)"
    end
    it 'show flight ranking of pilots after HC pilot' +
       ' as if HC pilot had not flown' do
      next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
      known_rank = next_row.find(:xpath, "./td[@class='rank'][1]")
      expect(known_rank.text).to eq "(4)"
      free_rank = next_row.find(:xpath, "./td[@class='rank'][2]")
      expect(free_rank.text).to eq "(4)"
    end
  end
  context 'flight results' do
    before :each do
      visit flight_path(@known_flight)
      hc_pilot_link = find(:xpath,
        "//table[@class='flight_results']//tr/td[@class='pilot']" +
        "/a[contains(@href, '/pilots/#{@hc_pilot.id}')]")
      @hc_pilot_cell = hc_pilot_link.find(:xpath, "./ancestor::td[1]")
      @hc_row = hc_pilot_link.find(:xpath, "./ancestor::tr[1]")
    end
    it 'show "(patch)" for pilots flying HC' do
      expect(@hc_pilot_cell.text).to match /\(patch\)/
    end
    it 'show HC for ranking of pilot contest result' +
       ' where pf_result has hors_concours' do
      hc_rank = @hc_row.find(:xpath, "./td[@class='overall_rank'][last()]")
      expect(hc_rank.text).to eq "(HC)"
    end
    it 'show ranking of pilots after HC pilot as if HC pilot had not flown' do
      next_row = @hc_row.find(:xpath, 'following-sibling::tr[1]')
      next_rank = next_row.find(:xpath, "./td[@class='overall_rank'][last()]")
      expect(next_rank.text).to eq "(4)"
    end
  end
end
