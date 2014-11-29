module ACRO
  describe ParticipantList do
    before(:all) do
      @part_list = ParticipantList::new
      @members = participant_list_members
    end

    it 'writes and reads back' do
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
