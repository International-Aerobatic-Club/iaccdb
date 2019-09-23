module Manny
  describe MannyToDB do
    before(:each) do 
      manny = Manny::Parse.new
      IO.foreach('spec/manny/Contest_300.txt') { |line| manny.processLine(line) }
      m2d = Manny::MannyToDB.new
      @contest = m2d.process_contest(manny, true)
    end
    it 'captures a contest' do
      expect(@contest).not_to be nil
      expect(@contest.start.day).to eq(22)
      expect(@contest.start.year).to eq(2010)
      expect(@contest.start.month).to eq(10)
      expect(@contest.name).to eq('Phil Schacht Aerobatic Finale 2010')
      expect(@contest.region).to eq('SouthEast')
      expect(@contest.director).to eq('Charlie Wilkinson')
      expect(@contest.city).to eq('Keystone Heights')
      expect(@contest.state).to eq('FL')
      expect(@contest.chapter).to eq(288)
    end
    it 'captures the primary known sequence' do
      flight = @contest.flights.first
      expect(flight).not_to be nil
      pilot_flight = flight.pilot_flights.first
      expect(pilot_flight).not_to be nil
      sequence = pilot_flight.sequence
      expect(sequence).not_to be nil
      expect(sequence.k_values).to eq([7, 15, 14, 10, 4, 10, 3])
    end
    it 'captures a sportsman submitted free for a second flight' do
      category = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Free')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Hartvigsen').first
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      expect(pilot_flight).not_to be nil
      sequence = pilot_flight.sequence
      expect(sequence).not_to be nil
      expect(sequence.k_values).to eq( 
        [11, 17, 10, 13, 18, 3, 18, 11, 6, 9, 4, 10, 7, 6]
      )
    end
    it 'captures a sportsman submitted free for a third flight' do
      category = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Unknown')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Hartvigsen').first
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      expect(pilot_flight).not_to be nil
      sequence = pilot_flight.sequence
      expect(sequence).not_to be nil
      expect(sequence.k_values).to eq( 
        [11, 17, 10, 13, 18, 3, 18, 11, 6, 9, 4, 10, 7, 6]
      )
    end
    it 'captures the sportsman known for a second flight' do
      category = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Unknown')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Cohen').first
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      expect(pilot_flight).not_to be nil
      sequence = pilot_flight.sequence
      expect(sequence).not_to be nil
      expect(sequence.k_values).to eq( 
        [7, 13, 16, 13, 19, 18, 13, 10, 18, 10, 6]
      )
    end
    it 'gets the intermediate unknown' do
      category = Category.find_for_cat_aircat('Intermediate', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Unknown')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Wells').first
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      expect(pilot_flight).not_to be nil
      sequence = pilot_flight.sequence
      expect(sequence).not_to be nil
      expect(sequence.k_values).to eq( 
        [25, 14, 12, 15, 19, 25, 31, 11, 23, 8]
      )
    end
    it 'captures scores' do
      category = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Free')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Cohen').first # manny_id 6
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot).first
      expect(pilot_flight).not_to be nil
      judge = Member.where(:family_name => 'Wells').first # manny_id 13
      expect(judge).not_to be nil
      assist = Member.where(:family_name => 'Davis').first
      expect(assist).not_to be nil
      judge_team = Judge.where(:judge_id => judge, :assist_id => assist)
      scores = pilot_flight.scores.where(:judge_id => judge_team).first
      expect(scores).not_to be nil
      expect(scores.values).to eq( 
        [85, 90, 65, 100, 80, 85, 90, 100, 0, 90, 85]
      )
    end
    it 'captures penalties' do
      category = Category.find_for_cat_aircat('Sportsman', 'P')
      flight = category.flights.find_by(contest: @contest, name: 'Free')
      expect(flight).not_to be nil
      pilot = Member.where(:family_name => 'Cohen').first # manny_id 6
      expect(pilot).not_to be nil
      pilot_flight = flight.pilot_flights.where(:pilot_id => pilot.id).first
      expect(pilot_flight).not_to be nil
      expect(pilot_flight.penalty_total).to eq(10)
    end
    it 'captures participants' do
      part = Member.where(:given_name => 'Frederick').first
      expect(part.family_name).to eq('Weaver')
      expect(part.iac_id).to eq(1017)
      part = Member.where(:family_name => 'Wilkinson').first
      expect(part.given_name).to eq('Charlie')
      expect(part.iac_id).to eq(433543)
    end
  end
end
