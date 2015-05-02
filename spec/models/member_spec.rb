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

  it 'creates a member if iac_id and family_name do not match, and\
    name matches multiple records' do
    bp_1 = Member.create(iac_id: 203803, family_name: 'Paulie', given_name: 'Bart')
    bp_2 = Member.create(iac_id: 203003, family_name: 'Paulie', given_name: 'Bart')
    # two records with same given and family names
    found = Member.find_or_create_by_iac_number(203103, 'Bart', 'Paulie')
    expect(found).to_not be nil
    expect(found.id).to_not eq bp_1.id
    expect(found.id).to_not eq bp_2.id
    expect(found.iac_id).to eq 203103
    expect(found.given_name).to eq 'Bart'
    expect(found.family_name).to eq 'Paulie'
  end

  it 'finds matching iac_id, family_name if multiple iac_id with different family_name' do
    iac_number = 206806
    mr_1 = Member.create(iac_id: iac_number, 
      family_name: 'Griffim', given_name: 'Patrick')
    mr_2 = Member.create(iac_id: iac_number, 
      family_name: 'Grifwith', given_name: 'Patrick')
    mr_3 = Member.create(iac_id: iac_number, 
      family_name: 'Griffith', given_name: 'Patrick')
    mr_4 = Member.create(iac_id: iac_number, 
      family_name: 'Griffin', given_name: 'Patrick')
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'Griffim')
    expect(found).to eq mr_1
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'Grifwith')
    expect(found).to eq mr_2
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'Griffith')
    expect(found).to eq mr_3
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'Griffin')
    expect(found).to eq mr_4
  end

  it 'merges two members' do
    mr_1 = create(:member)
    mr_2 = create(:member)
    mr_1.merge_member(mr_2)
    expect(Members.find(mr_2.id)).to match_array([])
    expect(Members.find(mr_1.id)).to match_array([mr_1])
  end

end
