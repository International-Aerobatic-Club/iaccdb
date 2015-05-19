RSpec.describe 'admin member merge', :type => :feature do

  before :example do
    @member_list = []
    12.times do
      @member_list << create(:member)
    end
    expect(Member.all.count).to eq @member_list.count
    http_auth_login
    visit admin_members_path
    expect(page.status_code).to eq 200
    within "ul.title-area" do
      within "h1" do
        expect(page).to have_content 'IAC CDB'
      end
    end
  end

  def select_members_and_merge
    tbody = find('tbody')
    tbody.check("selected_#{@member_list[0].id}")
    tbody.check("selected_#{@member_list[1].id}")
    tbody.check("selected_#{@member_list[2].id}")
    tbody.check("selected_#{@member_list[3].id}")
    tbody.all('tr').first.all('td').last.click_button('merge')
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
      expect(page).to have_content MemberMerge.role_name(:competitor)
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
      expect(page).to have_content MemberMerge.role_name(:competitor)
      expect(page).to have_content MemberMerge.role_name(:line_judge)
      expect(page).to have_content pf.flight.displayName
      expect(page).to have_content pf.contest.year_name
    end
  end

  it 'shows both overlaps and collisions when both occur' do
    fail
  end

  it 'shows flights for line judge' do
    fail
  end

  it 'shows flights for line assist judge' do
    fail
  end

  it 'shows flights for chief judge' do
    fail
  end

  it 'shows flights for chief assist judge' do
    fail
  end

  it 'shows flights for competitor' do
    fail
  end

  it 'invokes merge on selected members' do
    fail
  end
end
