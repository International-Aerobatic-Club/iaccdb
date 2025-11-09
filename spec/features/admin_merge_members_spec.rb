RSpec.describe 'admin member merge', type: :feature do

  def click_merge
    find(:xpath, "//tbody/tr[1]/td[position()=last()]/input").click
  end

  def select_members_and_merge
    expect(page).to have_xpath('//table/tbody/tr[4]/td[1]')
    (0..3).each do |m|
      find("input#selected_#{@member_list[m].id}").set(true)
    end
    click_merge
  end

  before :example do
    @member_list = create_list(:member, 12)
    basic_auth_visit(admin_members_path)
  end

  it 'displays the member list' do
    expect(Member.all.count).to eq @member_list.count
    begin
      expect(page.status_code).to eq 200
    rescue Capybara::NotSupportedByDriverError
      within "ul.title-area" do
        within "h1" do
          expect(page).to have_content 'IAC CDB'
        end
      end
    end
  end

  it 'enables select members for merge' do
    within "tbody" do
      rows = all("tr")
      expect(rows.count).to eq @member_list.count
    end
    select_members_and_merge
  end

  it 'shows collisions with a warning' do
    pf = create :pilot_flight, pilot: @member_list[0]
    create :pilot_flight, flight: pf.flight, pilot: @member_list[1]
    select_members_and_merge
    expect(page).to have_css 'p#alert'
    within 'p#alert' do
      expect(page).to have_content 'Data will be lost.'
    end
    expect(page).to_not have_css 'p#notice'
    expect(page).to have_css 'div#collisions'
    within 'div#collisions' do
      expect(page).to have_content MemberMerge::RoleFlight.role_name(:competitor)
      expect(page).to have_content pf.flight.displayName
      expect(page).to have_content pf.contest.year_name
    end
  end

  it 'shows overlaps with a warning' do
    pf = create :pilot_flight, pilot: @member_list[0]
    jp = create :judge, judge: @member_list[0]
    create :score, judge: jp, pilot_flight: pf
    select_members_and_merge
    expect(page).to have_css 'p#notice'
    within 'p#notice' do
      expect(page).to have_content 'different roles on the same flight'
    end
    expect(page).to_not have_css 'p#alert'
    expect(page).to have_css 'div#overlaps'
    within 'div#overlaps' do
      expect(page).to have_content MemberMerge::RoleFlight.role_name(:competitor)
      expect(page).to have_content MemberMerge::RoleFlight.role_name(:line_judge)
      expect(page).to have_content pf.flight.displayName
      expect(page).to have_content pf.contest.year_name
    end
  end

  it 'shows both overlaps and collisions when both occur' do
    pf = create :pilot_flight, pilot: @member_list[0]
    create :pilot_flight, flight: pf.flight, pilot: @member_list[1]
    jp = create :judge, judge: @member_list[0]
    create :score, judge: jp, pilot_flight: pf
    select_members_and_merge
    expect(page).to have_css 'p#alert'
    expect(page).to have_css 'p#notice'
    expect(page).to have_css 'div#overlaps'
    expect(page).to have_css 'div#collisions'
  end

  it 'shows flights for line judge' do
    (0..3).each do |m|
      jp = create :judge, judge: @member_list[m]
      create :score, judge: jp
    end
    select_members_and_merge
    expect(page).to have_content MemberMerge::RoleFlight.role_name(:line_judge)
    expect(page).to have_css '#contest_role_line_judge'
    within '#contest_role_line_judge' do
      expect(all('li').count).to eq 4
    end
  end

  it 'shows flights for line assist judge' do
    (0..3).each do |m|
      jp = create :judge, assist: @member_list[m]
      create :score, judge: jp
    end
    select_members_and_merge
    expect(page).to have_content MemberMerge::RoleFlight.role_name(:assist_line_judge)
    expect(page).to have_css '#contest_role_assist_line_judge'
    within '#contest_role_assist_line_judge' do
      expect(all('li').count).to eq 4
    end
  end

  it 'shows flights for chief judge' do
    (0..3).each do |m|
      create :flight, chief: @member_list[m]
    end
    select_members_and_merge
    expect(page).to have_content MemberMerge::RoleFlight.role_name(:chief_judge)
    expect(page).to have_css '#contest_role_chief_judge'
    within '#contest_role_chief_judge' do
      expect(all('li').count).to eq 4
    end
  end

  it 'shows flights for chief assist judge' do
    (0..3).each do |m|
      create :flight, assist: @member_list[m]
    end
    select_members_and_merge
    expect(page).to have_content MemberMerge::RoleFlight.role_name(:assist_chief_judge)
    expect(page).to have_css '#contest_role_assist_chief_judge'
    within '#contest_role_assist_chief_judge' do
      expect(all('li').count).to eq 4
    end
  end

  it 'shows flights for competitor' do
    (0..3).each do |m|
      create :pilot_flight, pilot: @member_list[m]
    end
    select_members_and_merge
    expect(page).to have_content MemberMerge::RoleFlight.role_name(:competitor)
    expect(page).to have_css '#contest_role_competitor'
    within '#contest_role_competitor' do
      expect(all('li').count).to eq 4
    end
  end

  it 'returns to member selection page if no members selected' do
    click_merge
    expect(page).to have_css('p#alert')
    within('p#alert') do
      expect(page).to have_content('select two or more members to merge')
    end
    expect(page).to have_content('Admin Members')
    expect(page).to have_xpath('//table/tbody/tr[4]/td[1]')
  end

  it 'invokes merge on selected members' do
    pending 'resolution of alert'
    (0..3).each do |m|
      create :pilot_flight, pilot: @member_list[m]
      jp = create :judge, judge: @member_list[m]
      create :score, judge: jp
      jp = create :judge, assist: @member_list[m]
      create :score, judge: jp
    end
    expect(Score.all.count).to eq 8
    expect(Judge.all.count).to eq 8
    select_members_and_merge
    accept_alert 'Be careful' do
      click_on('merge')
    end
    fail
    visit admin_members_path
  end
end
