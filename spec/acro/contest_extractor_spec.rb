require 'spec_helper'

module ACRO
  describe ContestExtractor do
    before :all do
      cs = ContestExtractor.new('spec/acro/newContest.yml')
      cs.scrape_contest
    end
    it 'creates pilot flight yml files' do
      expect(File.exists?('spec/acro/pilot_p001s16.htm.yml')).to eq true
      expect(File.exists?('spec/acro/pilot_p002s17.htm.yml')).to eq true
      expect(File.exists?('spec/acro/pilot_p035s09.htm.yml')).to eq true
    end
    it 'creates category yml files' do
      expect(File.exists?('spec/acro/multi_R011s08s17s26.htm.yml')).to eq true
    end
  end
end
