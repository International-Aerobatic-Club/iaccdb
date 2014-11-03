RSpec.describe Result, :type => :model do
  describe 'associations' do
    it 'relates to members and pc_results' do
      r = create(:result_with_members)
      expect(r.pilot).to_not be_nil
      results = r.pilot.results.all
      expect(results.include?(r)).to eq true
      expect(r.members).to_not be_nil
      r.members.each do |m|
        teams = m.teams.all
        expect(teams.include?(r)).to eq true
      end
      expect(r.pc_results).to_not be_nil
      r.pc_results.each do |accum|
        ar = accum.results.all
        expect(ar.include?(r)).to eq true
      end
    end
  end
end
