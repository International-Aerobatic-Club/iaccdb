describe 'contest category display' do
  before :context do
    @contest = create(:contest)
    @flight = create(:flight, contest: @contest)
    @pilot_flights = create_list(:pilot_flight, 7, flight: @flight)
    computer = ContestComputer.new(@contest)
    computer.compute_results
  end
  def pilot_link(pilot)
    find(:xpath,
      "//table[@class='pilot_results']//tr/td[@class='pilot'][1]/a[contains(@href, '/pilots/#{pilot.id}')]")
  end
  def pilot_row(pilot)
    pilot_link(pilot).find(:xpath, "./ancestor::tr[1]")
  end
  it 'shows make, model, and registration' do
    visit contest_path(@contest)
    @pilot_flights.each do |pf|
      pilot = pf.pilot
      pr = pilot_row(pilot)
      airplane_cell = pr.find(:xpath, "./td[@class='airplane']")
      expect(airplane_cell).to have_content(pf.airplane.make)
      expect(airplane_cell).to have_content(pf.airplane.model)
      expect(airplane_cell).to have_content(pf.airplane.reg)
    end
  end
  it 'shows pilot name' do
    visit contest_path(@contest)
    @pilot_flights.each do |pf|
      pilot = pf.pilot
      pc = pilot_link(pilot).find(:xpath, "./ancestor::td[1]")
      expect(pc).to have_content(pilot.family_name)
      expect(pc).to have_content(pilot.given_name)
    end
  end
end
