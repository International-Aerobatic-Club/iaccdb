require 'spec_helper'

module ACRO
  describe MemberList do

    before(:all) do
      @member_list = MemberList::new('spec/acro')
    end

    it 'finds by exact match' do
      rl = @member_list.by_first_last('Bill','Denton')
      expect(rl).to_not be_nil
      rl.each do |r|
        expect(r['given_name'].strip.downcase).to eq 'bill'
        expect(r['family_name'].strip.downcase).to eq 'denton'
      end
    end

    it 'finds by initials' do
      rl = @member_list.by_fi_li('Mark','Matticola')
      expect(rl).to_not be_nil
      expect(rl.count).to eq 26
      rl.each do |r|
        expect(r['given_name'].strip.downcase[0]).to eq 'm'
        expect(r['family_name'].strip.downcase[0]).to eq 'm'
      end
    end

    it 'finds by first two initials' do
      rl = @member_list.by_f2_l2('Mark','Matticola')
      expect(rl).to_not be_nil
      expect(rl.count).to eq 5
      rl.each do |r|
        expect(r['given_name'].strip.downcase[0,2]).to eq 'ma'
        expect(r['family_name'].strip.downcase[0,2]).to eq 'ma'
      end
    end

    it 'finds by last_name' do
      rl = @member_list.by_last('Matticola')
      expect(rl).to_not be_nil
      expect(rl.count).to eq 3
      rl.each do |r|
        expect(r['family_name'].strip.downcase).to eq 'matticola'
      end
    end

    it 'finds by last_name two initials' do
      rl = @member_list.by_l2('Matticola')
      expect(rl).to_not be_nil
      expect(rl.count).to eq 77
      rl.each do |r|
        expect(r['family_name'].strip.downcase[0,2]).to eq 'ma'
      end
    end

  end
end
