describe 'show contest' do
  def build_contest_category_flights(contest, category, chief)
    first = create(:flight, contest: contest, category: category,
      chief: chief)
    second = create(:flight, contest: contest, category: category,
      chief: chief, name: 'Free')
    third = create(:flight, contest: contest, category: category,
      chief: chief, name: 'Unknown')
    pfs = create_list(:pilot_flight, 7, flight: first)
    [second, third].each do |flight|
      pfs.each do |pf|
        create(:pilot_flight, pilot: pf.pilot, airplane: pf.airplane,
          flight: flight)
      end
    end
    [first, second, third]
  end
  context 'multiple chiefs' do
    before :context do
      @contest = create(:contest)
      spn = Category.find_by(aircat: 'P', category: 'sportsman')
      imdt = Category.find_by(aircat: 'P', category: 'intermediate')
      @cjs = create(:member)
      @cji = create(:member)
      @spn_flights = build_contest_category_flights(@contest, spn, @cjs)
      @imdt_flights = build_contest_category_flights(@contest, imdt, @cji)
      computer = ContestComputer.new(@contest)
      computer.compute_results
    end
    it 'shows chief judge rollup for contest' do
      visit contest_path(@contest)
      within 'div#content p.contest_chief' do
        expect(page).to have_content('Chief Judge(s)')
        expect(page).to have_content(@cjs.name)
        expect(page).to have_content(@cji.name)
      end
    end
    it 'shows chief judge rollup for category' do
      cj2 = create(:member)
      fspn = @spn_flights.first
      fspn.chief = cj2
      fspn.save!
      visit contest_path(@contest)
      spnh = find(:xpath, "//div[@id='content']/h3[text()='#{fspn.category.name}']")
      ptbl = spnh.first(:xpath, "following-sibling::table[@class='pilot_results']")
      expect(ptbl).to_not be nil
      pfcj = ptbl.first(:xpath, "following-sibling::p[@class='category-chief']")
      expect(pfcj).to_not be nil
      expect(pfcj).to have_content('Chief Judge(s)')
      expect(pfcj).to have_content(@cjs.name)
      expect(pfcj).to have_content(cj2.name)
    end
  end
  context 'no chiefs' do
    before :context do
      @contest = create(:contest)
      spn = Category.find_by(aircat: 'P', category: 'sportsman')
      build_contest_category_flights(@contest, spn, nil)
      computer = ContestComputer.new(@contest)
      computer.compute_results
    end
    it 'does not show contest chiefs stem' do
      visit contest_path(@contest)
      expect(page).to_not have_css('p.contest_chief');
    end
    it 'does not show category chiefs stem' do
      visit contest_path(@contest)
      expect(page).to_not have_css('p.category-chief');
    end
  end
  it 'does not show chief on categories when same for all' do
    @contest = create(:contest)
    spn = Category.find_by(aircat: 'P', category: 'sportsman')
    imdt = Category.find_by(aircat: 'P', category: 'intermediate')
    @cj = create(:member)
    @spn_flights = build_contest_category_flights(@contest, spn, @cj)
    @imdt_flights = build_contest_category_flights(@contest, imdt, @cj)
    computer = ContestComputer.new(@contest)
    computer.compute_results
    visit contest_path(@contest)
    expect(page).to_not have_css('p.category-chief');
  end
end

