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
  before :context do
    @contest = create(:contest)
    spn = Category.find_by(aircat: 'P', category: 'sportsman')
    imdt = Category.find_by(aircat: 'P', category: 'intermediate')
    @cjs = create(:member)
    @cji = create(:member)
    @spn_flights = build_contest_category_flights(@contest, spn, @cjs)
    @imdt_flights = build_contest_category_flights(@contest, imdt, @cjs)
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
end

