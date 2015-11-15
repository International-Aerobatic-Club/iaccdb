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

  it 'creates new record if iac_id, given_name, and family_name do not match' do
    iac_id = 201801
    given_name = 'Smart'
    jenkins_record = Member.create(iac_id: iac_id, family_name: 'Jenkins',
      given_name: given_name)
    # Member 201801, Jenkins, Smart

    jergins_iac_id = 208801
    family_name = 'Jergins'
    jergins_record = Member.create(iac_id: jergins_iac_id, family_name: family_name,
      given_name: given_name)
    # Member 208801, Jergins, Smart

    new_record = Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
    # Looked for 201801, Jergins, Smart

    # Expect to get 201801, Jergins, Smart
    # Not 201801, Jenkins, Smart
    # Not 208801, Jergins, Smart
    expect(new_record).to_not be nil
    expect(new_record.id).to_not eq jenkins_record.id
    expect(new_record.id).to_not eq jergins_record.id
    expect(new_record.iac_id).to eq iac_id
    expect(new_record.given_name).to eq given_name
    expect(new_record.family_name).to eq family_name
  end

  it 'returns name match if no iac_id' do
    given_name = 'Smart'
    family_name = 'Jenkins'
    existing_record = Member.create(iac_id: 201801, family_name: family_name,
      given_name: given_name)
    # Member 201801, Jenkins, Smart

    found_record = Member.find_or_create_by_iac_number(0, given_name, family_name)
    expect(found_record.id).to eq existing_record.id
  end

  it 'creates new record if no iac_id and multiple name matches' do
    given_name = 'Smart'
    family_name = 'Jenkins'
    existing_record = Member.create(iac_id: 201801, family_name: family_name,
      given_name: given_name)
    # Member 201801, Jenkins, Smart

    second_record = Member.create(iac_id: 206801, family_name: family_name, given_name: given_name)
    # Member 206801, Jenkins, Smart

    new_record = Member.find_or_create_by_iac_number(0, given_name, family_name)
    # Member 0, Jenkins, Smart

    expect(new_record.id).to_not eq existing_record.id
    expect(new_record.id).to_not eq second_record.id
    expect(new_record.iac_id).to eq 0
    expect(new_record.given_name).to eq given_name
    expect(new_record.family_name).to eq family_name
  end

  it 'creates new record if iac_id and family_name do not match, and\
    name matches multiple records' do
    bp_1 = Member.create(iac_id: 203803, family_name: 'Paulie', given_name: 'Bart')
    bp_2 = Member.create(iac_id: 203003, family_name: 'Paulie', given_name: 'Bart')
    # two records with same given and family names
    new_record = Member.find_or_create_by_iac_number(203103, 'Bart', 'Paulie')
    expect(new_record).to_not be nil
    expect(new_record.id).to_not eq bp_1.id
    expect(new_record.id).to_not eq bp_2.id
    expect(new_record.iac_id).to eq 203103
    expect(new_record.given_name).to eq 'Bart'
    expect(new_record.family_name).to eq 'Paulie'
  end

  it 'finds matching iac_id, family_name if same iac_id with multiple family_names' do
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

  it 'finds matching iac_id, family_name if different iac_id with same family_name' do
    family_name = 'Griffim'
    given_name = 'Patrick'
    mr_1 = Member.create(iac_id: 206806, 
      family_name: family_name, given_name: given_name)
    mr_2 = Member.create(iac_id: 201806, 
      family_name: family_name, given_name: given_name)
    iac_number = 206801
    mr_3 = Member.create(iac_id: iac_number, 
      family_name: family_name, given_name: given_name)
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'Griffim')
    expect(found).to eq mr_3
  end

  it 'finds first matching iac_id, family_name if multiple with same iac_id and family_name' do
    family_name = 'Griffim'
    given_name = 'Patrick'
    iac_number = 206806
    mr_1 = Member.create(iac_id: iac_number,
      family_name: family_name, given_name: given_name)
    mr_2 = Member.create(iac_id: iac_number,
      family_name: family_name, given_name: given_name)
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', family_name)
    expect(found.id).to eq mr_1.id
  end

  it 'finds first matching iac_id, family_name when case mismatch family_name' do
    family_name = 'Griffim'
    given_name = 'Patrick'
    iac_number = 206806
    mr_1 = Member.create(iac_id: iac_number,
      family_name: family_name, given_name: given_name)
    mr_2 = Member.create(iac_id: iac_number,
      family_name: family_name, given_name: given_name)
    found = Member.find_or_create_by_iac_number(iac_number, 'Pat', 'GrIfFiM')
    expect(found.id).to eq mr_1.id
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

  it 'returns contests participated as pilot' do
    member = create :member
    category = Category.last
    4.times do
      contest = create(:contest, start: '2015-07-30')
      pcr = PcResult.new(pilot: member, category: category, contest: contest)
      pcr.save
    end
    contests = member.contests(2015)
    expect(contests.count).to eq 4
  end

end
