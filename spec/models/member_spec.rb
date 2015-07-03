describe Member, :type => :model do
  it 'correctly identifies member with given iac id and family name' do
    iac_id = 212020
    family_name = 'Sinatra'
    given_name = 'Frank'
    existing = Member.create(iac_id: iac_id, family_name: family_name,
      given_name: given_name)
    found = Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
    expect(found).to_not be nil
    expect(found.id).to eq existing.id
  end

  it 'resorts to name match if iac_id and family_name do not match' do
    iac_id = 201801
    given_name = 'Smart'
    existing_iac_id = Member.create(iac_id: iac_id, family_name: 'Jenkins',
      given_name: given_name)
    # Member 201801, Jenkins, Smart
    jergins_iac_id = 208801
    family_name = 'Jergins'
    existing_name = Member.create(iac_id: jergins_iac_id, family_name: family_name,
      given_name: given_name)
    # Member 208801, Jergins, Smart
    found = Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
    # Looked for 201801, Jergins, Smart
    # Expect to get 208801, Jergins, Smart
    expect(found).to_not be nil
    expect(found.id).to eq existing_name.id
    expect(found.iac_id).to eq jergins_iac_id
    expect(found.family_name).to eq family_name
  end

  it 'matches on soundex similarity with family name and iac id' do
    bp_1 = Member.create(iac_id: 203803, family_name: 'Paulie', given_name: 'Bart')
    bp_2 = Member.create(iac_id: 203003, family_name: 'Paulie', given_name: 'Bart')
    # two records with same given and family names
    found = Member.find_or_create_by_iac_number(203803, 'Bart', 'Paulee')
    expect(found).to_not be nil
    expect(found.id).to_not eq bp_2.id
    expect(found.id).to eq bp_1.id
    expect(found.given_name).to eq 'Bart'
    expect(found.family_name).to eq 'Paulie'
  end

  it 'matches on soundex similarity with given and family name when iac id and family name mismatch' do
    bp_1 = Member.create(iac_id: 203803, given_name: 'Barrie', family_name: 'Wyte')
    bp_2 = Member.create(iac_id: 203003, given_name: 'Barr', family_name: 'Paul')
    found = Member.find_or_create_by_iac_number(203003, 'Barry', 'White')
    expect(found).to_not be nil
    expect(found.id).to_not eq bp_2.id
    expect(found.id).to eq bp_1.id
    expect(found.given_name).to eq 'Barrie'
    expect(found.family_name).to eq 'Wyte'
  end

  it 'finds matching iac_id, family_name by soundex if multiple iac_id with different family_name' do
    iac_number = 206806
    mr_1 = Member.create(iac_id: iac_number, 
      family_name: 'Griffith', given_name: 'Patrick')
    mr_2 = Member.create(iac_id: iac_number, 
      family_name: 'Carter', given_name: 'Patrick')
    mr_3 = Member.create(iac_id: iac_number, 
      family_name: 'Midler', given_name: 'Patrick')
    mr_4 = Member.create(iac_id: iac_number, 
      family_name: 'Seeger', given_name: 'Patrick')
    found = Member.find_or_create_by_iac_number(iac_number, 'Patric', 'Grifith')
    expect(found).to eq mr_1
    found = Member.find_or_create_by_iac_number(iac_number, 'Patric', 'Carter')
    expect(found).to eq mr_2
    found = Member.find_or_create_by_iac_number(iac_number, 'Patric', 'Middler')
    expect(found).to eq mr_3
    found = Member.find_or_create_by_iac_number(iac_number, 'Patric', 'Sieger')
    expect(found).to eq mr_4
  end

  it 'returns the same member repeatedly as missing member' do
    member = Member.missing_member
    mmid = member.id
    3.times do
      member = Member.missing_member
      expect(member.id).to eq mmid
    end
    expect(member.given_name).to eq 'Missing'
    expect(member.family_name).to eq 'Member'
  end

end
