require 'spec_helper'
require 'acro/contestScraper'

module ACRO
  describe ContestScraper do
    it 'creates a new contest' do
      ct = Contest.where(:start => '2011-09-25')
      ct.empty?.should == true
      cs = ContestScraper.new('spec/acro/newContest.yml')
      ct = Contest.where(:start => '2011-09-25').first
      cs.dContest.should == ct
    end
    it 'finds an existing contest' do
      ec = Factory(:existing_contest)
      cs = ContestScraper.new('spec/acro/existingContest.yml')
      cs.dContest.should == ec
    end
    it 'finds missing data' do
      lambda { 
        ContestScraper.new('spec/acro/faultyContest.yml')
      }.should raise_error('Missing data for contest city')
    end
    it 'finds pilot data files' do
      cs = ContestScraper.new('spec/acro/newContest.yml')
      cs.files.size.should == 6
    end
    it 'creates judge member records' do
    end
    it 'finds existing judge members' do
    end
    it 'creates pilot member records' do
    end
    it 'finds existing pilot members' do
    end
    it 'creates flight records' do
    end
    it 'adds to existing flight records' do
    end
    it 'adds pilot flight scores' do
    end
  end
end
