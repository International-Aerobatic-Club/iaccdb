require 'rails_helper'
require 'shared/hors_concours_context'

RSpec.feature "HorsConcours", type: :feature, viz: true do
  include_context 'hors_concours flight'
  context 'category results' do
    before :each do
      visit contest_path(@contest.id)
    end
    it 'show HC for ranking of pilot contest result where pc_result has hors_concours' do
      save_and_open_page
      find(:xpath, '//th/a[contains(@text, "Known")]')
      sleep 30
      fail
    end
    it 'show ranking of pilots after HC pilot as if HC pilot had not flown' do
      fail
    end
  end
  context 'flight results' do
    it 'show HC for ranking of pilot contest result where pf_result has hors_concours' do
      fail
    end
    it 'show ranking of pilots after HC pilot as if HC pilot had not flown' do
      fail
    end
  end
end
