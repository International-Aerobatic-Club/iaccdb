require 'xml'

module Jasper
  describe JasperToDB do

    # provide only the file name and place the file in SAMPLE_FILE_DIR
    SAMPLE_FILE_DIR = 'spec/fixtures/jasper'
    def jasperParseFromTestDataFile(filename)
      testFile = File.join(SAMPLE_FILE_DIR, filename)
      jasper = Jasper::JasperParse.new
      parser = XML::Parser.file(testFile)
      jasper.do_parse(parser)
      jasper
    end

    context 'jasperResultsFormat data test' do
      before(:context) do
        jasper = jasperParseFromTestDataFile('jasperResultsFormat.xml')
        2.times do
          Member.create!(iac_id: 0, given_name: 'David', family_name: 'Crescenzo')
        end
        j2d = Jasper::JasperToDB.new
        @contest = j2d.process_contest(jasper)
      end
      it 'captures a contest' do
        expect(@contest).not_to be_nil
        expect(@contest.id).not_to be_nil
        expect(@contest.name).to eq("Test Contest US Candian Challenge")
        expect(@contest.start.day).to eq(23)
        expect(@contest.start.year).to eq(2014)
        expect(@contest.start.month).to eq(12)
        expect(@contest.region).to eq('NorthEast')
        expect(@contest.director).to eq('Pat Barrett')
        expect(@contest.city).to eq('Olean')
        expect(@contest.state).to eq('NY')
        expect(@contest.chapter).to eq(126)
      end
      it 'captures flights' do
        cat = Category.find_for_cat_aircat('Unlimited', 'P')
        flights = @contest.flights.where(:category_id => cat.id, :name => 'Unknown')
        expect(flights.count).to eq(1)
        expect(flights.first.chief.iac_id).to eq(2383)
        expect(flights.first.assist.iac_id).to eq(18515)
      end
      it 'captures pilots' do
        pilot = Member.find_by_iac_id(434969)
        expect(pilot).not_to be_nil
        expect(pilot.given_name).to eq('Desmond')
        expect(pilot.family_name).to eq('Lightbody')
      end
      it 'maps member name to a single member record' do
        boks = Member.where(given_name: 'Hans', family_name: 'Bok')
        expect(boks.count).to eq 1
      end
      it 'maps ambiguous member name to a single member record' do
        crecs = Member.where(given_name: 'David', family_name: 'Crescenzo')
        # the context set-up two existing records that duplicate this name.
        # the db mapper should create exactly one more.
        expect(crecs.count).to eq 3
      end
      it 'captures judge teams' do
        judge = Member.where(:iac_id => 431885).first
        expect(judge).not_to be_nil
        expect(judge.given_name).to eq('Sanford')
        expect(judge.family_name).to eq('Langworthy')
        assistant = Member.where(:iac_id => 433272).first
        expect(assistant).not_to be_nil
        expect(assistant.given_name).to eq('Hella')
        expect(assistant.family_name).to eq('Comat')
        judge_team = Judge.where(:judge_id => judge.id, :assist_id => assistant.id).first
        expect(judge_team).not_to be_nil
      end
      it 'captures pilot flights' do
        cat = Category.find_for_cat_aircat('Intermediate', 'P')
        flight = @contest.flights.where(:category_id => cat.id, :name => 'Unknown').first
        pilot = Member.find_by_iac_id(10467)
        pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
        expect(pilot_flight).not_to be_nil
        expect(pilot_flight.penalty_total).to eq(100)
      end
      it 'captures airplanes' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where( :name => 'Known', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:family_name => 'Ernewein').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        airplane = pilot_flight.airplane
        expect(airplane).not_to be_nil
        expect(airplane.make).to eq('Bucker Youngman')
        expect(airplane.model).to eq('131')
        expect(airplane.reg).to eq('CFLXE')
      end
      it 'captures known sequences' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where( :name => 'Known', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:family_name => 'Ernewein').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(11)
        expect(sequence.total_k).to eq(130)
        expect(sequence.k_values).to eq([17, 7, 4, 14, 15, 16, 14, 17, 10, 10, 6])
      end
      it 'captures free sequences' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where( :name => 'Free', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:family_name => 'Wieckowski').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(11)
        expect(sequence.total_k).to eq(133)
        expect(sequence.k_values).to eq([7, 14, 19, 18, 10, 14, 13, 16, 11, 5, 6])
      end
      it 'captures sportsman second free sequences' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where( :name => 'Unknown', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:family_name => 'Wieckowski').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(11)
        expect(sequence.total_k).to eq(133)
        expect(sequence.k_values).to eq([7, 14, 19, 18, 10, 14, 13, 16, 11, 5, 6])
      end
      it 'captures unknown sequences' do
        cat = Category.find_for_cat_aircat('Unlimited', 'P')
        flight = @contest.flights.where( :name => 'Unknown', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:iac_id => '13721').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(14)
        expect(sequence.total_k).to eq(420)
        expect(sequence.k_values).to eq([36, 31, 36, 33, 41, 42, 31, 26, 24, 20, 38, 25, 17, 20])
      end
      it 'captures second unknown sequences' do
        cat = Category.find_for_cat_aircat('Intermediate', 'P')
        flight = @contest.flights.where( :name => 'Unknown II', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:iac_id => '10467').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(16)
        expect(sequence.total_k).to eq(198)
        expect(sequence.k_values).to eq([10, 13, 10, 13, 4, 19, 18, 14, 19, 3, 17, 10, 19, 9, 12, 8])
      end
      it 'captures four minute free sequences' do
        cat = Category.find_for_cat_aircat('Four Minute', 'F')
        flight = @contest.flights.where(category_id: cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(iac_id: 13721).first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence = pilot_flight.sequence
        expect(sequence).not_to be_nil
        expect(sequence.figure_count).to eq(10)
        expect(sequence.total_k).to eq(400)
        expect(sequence.k_values).to eq([40, 40, 40, 40, 40, 40, 40, 40, 40, 40])
        pilot = Member.where(iac_id: 27381).first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        sequence2 = pilot_flight.sequence
        expect(sequence2.id).to eq(sequence.id)
      end
      it 'captures scores' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where( :name => 'Free', :category_id => cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(:family_name => 'Ernewein').first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        judge = Member.where(:family_name => 'Langworthy').first
        expect(judge).not_to be_nil
        assist = Member.where(:family_name => 'Comat').first
        expect(assist).not_to be_nil
        judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
        scores = pilot_flight.scores.where(:judge_id => judge_team).first
        expect(scores).not_to be_nil
        expect(scores.values).to eq( 
          [90, 95, 95, 90, 95, 90, 85, 95, 75, 90, 85]
        )
      end
      it 'captures four minute free scores' do
        cat = Category.find_for_cat_aircat('Four Minute', 'F')
        flight = @contest.flights.where(category_id: cat.id).first
        expect(flight).not_to be_nil
        pilot = Member.where(iac_id: 13721).first
        expect(pilot).not_to be_nil
        pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
        expect(pilot_flight).not_to be_nil
        judge = Member.where(iac_id: 434884)
        expect(judge).not_to be_nil
        assist = Member.where(iac_id: 434247)
        expect(assist).not_to be_nil
        judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
        scores = pilot_flight.scores.where(:judge_id => judge_team).first
        expect(scores).not_to be_nil
        expect(scores.values).to eq( 
          [80, 85, 75, 70, 50, 80, 100, 70, 65, 90]
        )
      end
      it 'captures collegiate teams' do
        teams = CollegiateResult.where(year: @contest.year)
        expect(teams.count).to eq 2
        team_names = teams.all.collect(&:name)
        expect(team_names).to include 'University of North Dakota'
        expect(team_names).to include 'United States Air Force Academy'
      end
      it 'captures collegiate participants' do
        usaf = CollegiateResult.where(year: @contest.year,
          name: 'United States Air Force Academy').first
        usaf_ids = usaf.members.collect(&:iac_id)
        expect(usaf_ids).to include 430273
        und = CollegiateResult.where(year: @contest.year,
          name: 'University of North Dakota').first
        und_ids = und.members.collect(&:iac_id)
        expect(und_ids).to include 10467
        expect(und_ids).to include 28094
        expect(und_ids.count).to eq 3
      end
      it 'filters pilot chapter number' do
        cat = Category.find_for_cat_aircat('Sportsman', 'P')
        flight = @contest.flights.where(category_id: cat.id, name: 'Known').first
        pilot = Member.find_by_iac_id(12058)
        pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
        expect(pilot_flight.chapter).to eq '3/52'
        pilot = Member.find_by_iac_id(430273)
        pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
        expect(pilot_flight.chapter).to eq '126/12'
        pilot = Member.find_by_iac_id(434969)
        pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
        expect(pilot_flight.chapter).to eq '3/126/12'
        pilot = Member.find_by_iac_id(434884)
        pilot_flight = PilotFlight.find_by_flight_id_and_pilot_id(flight.id, pilot.id)
        expect(pilot_flight.chapter).to eq '35/52'
      end
      it 'identifies pilots with (patch) on their names' do
        patch_pilots = Member.where(family_name: 'Thompson (patch)')
        expect(patch_pilots.count).to eq 0
        patch_pilots = Member.where(family_name: 'Thompson')
        expect(patch_pilots.count).to eq 1
        patch_flights = PilotFlight.where(pilot_id: patch_pilots.first.id)
        patch_flights.each do |pf|
          if pf.category.category == 'unlimited'
            expect(pf.hors_concours).to be true
          end
        end
      end
      it 'identifies solo performance in category' do
        pending 'solo performance data'
        fail
      end
      it 'identifies performances in lower categories' do
        pending 'lower category performance data'
        fail
      end
    end
    context 'before and after' do
      before(:context) do
        @jasper = jasperParseFromTestDataFile('jasperResultsFormat.xml')
        @j2d = Jasper::JasperToDB.new
      end
      it 'does not invent a new category' do
        catCt = Category.count
        @j2d.process_contest(@jasper)
        expect(Category.count).to eq catCt
      end
    end
  end
end

