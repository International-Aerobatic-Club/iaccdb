module ACRO
  describe ParticipantList do
    before(:all) do
      @members = participant_list_members
    end

    it 'writes and reads back' do
      part_list = ParticipantList::new
      part_list.read(CONTEST_DATA_FILE_PATH)
      m1 = part_list.participant(@members[0][:name])
      expect(m1).to_not be_nil
      expect(m1.db_id).to eq 1
      expect(m1.given_name).to eq 'Marvin'
      expect(m1.family_name).to eq 'Minsky'
      expect(m1.iac_id).to eq 21456
      m4 = part_list.participant(@members[4][:name])
      expect(m4.family_name).to eq 'Martin'
    end

    it 'gives a nil for missing participant' do
      name = 'missing'
      part_list = ParticipantList::new
      part_list.add(name, nil)
      expect(part_list.participant(name)).to be_nil
    end

    it 'fills-in new record given info without db id' do
      part_list = ParticipantList::new
      part_list.read(CONTEST_DATA_FILE_PATH)
      name = @members[5][:name]
      expect(name).to eq 'Robert Newhart'
      part = part_list.participant(name)
      expect(part).to_not be_nil
      expect(part.db_id).to be_nil
      expect(part.iac_id).to eq 21488
      expect(part.family_name).to eq 'Newheart'
    end

  end
end
