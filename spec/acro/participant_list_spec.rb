require 'spec_helper'

module ACRO
  describe ParticipantList do

    before(:all) do
      @members = [
        { name: 'Marv Miniski', 
          'id' => 1, 'given_name' => 'Marvin', 'family_name' => 'Minsky', 'iac_id' => 21456 },
        { name: 'Hatch Chaps', 
          'id' => 2, 'given_name' => 'Harry', 'family_name' => 'Chapin', 'iac_id' => 82345 },
        { name: 'Garvy Boy', 
          'id' => 3, 'given_name' => 'Jerry', 'family_name' => 'Garcia', 'iac_id' => 21456 },
        { name: 'Bobby See', 
          'id' => 4, 'given_name' => 'Bob', 'family_name' => 'Seeger', 'iac_id' => 21456 },
        { name: 'Marty Mark', 
          'id' => 5, 'given_name' => 'Mark', 'family_name' => 'Martin', 'iac_id' => 21456 }
      ]
      @part_list = ParticipantList::new
      @members.each do |m|
        @part_list.add(m[:name], m)
      end
    end

    after(:all) do
      File.delete('spec/acro/participant_list.yml')
    end

    it 'writes and reads back' do
      @part_list.write('spec/acro')
      npart_list = ParticipantList::new
      npart_list.read('spec/acro')
      m1 = npart_list.participant(@members[0][:name])
      expect(m1).to_not be_nil
      expect(m1.db_id).to eq 1
      expect(m1.given_name).to eq 'Marvin'
      expect(m1.family_name).to eq 'Minsky'
      expect(m1.iac_id).to eq 21456
      m4 = npart_list.participant(@members[4][:name])
      expect(m4.family_name).to eq 'Martin'
    end

    it 'gives a nil for missing participant' do
      name = 'missing'
      @part_list.add(name, nil)
      expect(@part_list.participant(name)).to be_nil
    end

  end
end
