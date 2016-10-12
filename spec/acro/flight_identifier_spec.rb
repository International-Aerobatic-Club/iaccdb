module ACRO
  describe FlightIdentifier do
    include FlightIdentifier

    it 'gets the basic categories' do
      expect(detect_flight_category('Primary')).to eq 'Primary'
      expect(detect_flight_category('Pri')).to eq 'Primary'
      expect(detect_flight_category('Beginner')).to eq 'Primary'
      expect(detect_flight_category('Sportsman')).to eq 'Sportsman'
      expect(detect_flight_category('Standard')).to eq 'Sportsman'
      expect(detect_flight_category('Advanced')).to eq 'Advanced'
      expect(detect_flight_category('Advanced')).to eq 'Advanced'
      expect(detect_flight_category('Intermediate')).to eq 'Intermediate'
      expect(detect_flight_category('Imdt')).to eq 'Intermediate'
      expect(detect_flight_category('Unlimited')).to eq 'Unlimited'
      expect(detect_flight_category('Unl')).to eq 'Unlimited'
      expect(detect_flight_category('Four')).to eq 'Four Minute'
      expect(detect_flight_category('Minute')).to eq 'Four Minute'
    end

    it 'gets the basic flights' do
      expect(detect_flight_name('Known')).to eq 'Known'
      expect(detect_flight_name('Primary Flight #1')).to eq 'Flight 1'
      expect(detect_flight_name('Primary Flight #2')).to eq 'Flight 2'
      expect(detect_flight_name('Primary 1st Flight')).to eq 'Flight 1'
      expect(detect_flight_name('Primary 2nd Flight')).to eq 'Flight 2'
      expect(detect_flight_name('Primary 3rd Flight')).to eq 'Flight 3'
      expect(detect_flight_name('Primary Flight #3')).to eq 'Flight 3'
      expect(detect_flight_name('Team Flight')).to eq 'Team Unknown'
      expect(detect_flight_name('Unknown')).to eq 'Unknown'
      expect(detect_flight_name('Free')).to eq 'Free'
    end

    it 'gets the basic class' do
      expect(detect_flight_aircat('Power')).to eq 'P'
      expect(detect_flight_aircat('Glider')).to eq 'G'
      expect(detect_flight_aircat('Four')).to eq 'F'
      expect(detect_flight_aircat('Minute')).to eq 'F'
      expect(detect_flight_aircat('Primary')).to eq 'P'
    end

    it 'gets "Basic : Programme 2: Known #2"' do
      description = 'Basic : Programme 2: Known #2'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 2'
      expect(detect_flight_category(description)).to eq 'Primary'
    end

    it 'gets "Beginners : Programme 2: Free Programme"' do
      description = 'Beginners : Programme 2: Free Programme'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 2'
      expect(detect_flight_category(description)).to eq 'Primary'
    end

    it 'gets "Beginners : Programme 3: Free Programme"' do
      description = 'Beginners : Programme 3: Free Programme'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 3'
      expect(detect_flight_category(description)).to eq 'Primary'
    end

    it 'gets "Intermediate - Glider : Programme 2: Free Programme"' do
      description = 'Intermediate - Glider : Programme 2: Free Programme'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free'
      expect(detect_flight_category(description)).to eq 'Intermediate'
    end

    it 'gets "Standard - Power : Programme 2: Free Programme"' do
      description = 'Standard - Power : Programme 2: Free Programme'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 2'
      expect(detect_flight_category(description)).to eq 'Sportsman'
    end

    it 'gets "Sports - Glider : Programme 3: Free Programme"' do
      description = 'Sports - Glider : Programme 3: Free Programme'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Flight 3'
      expect(detect_flight_category(description)).to eq 'Sportsman'
    end

    it 'gets "Unlimited - Power : Programme 1: Free Known"' do
      description = 'Unlimited - Power : Programme 1: Free Known'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Free Known'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Unlimited - Power : Programme 2: Free Unknown #1"' do
      description = 'Unlimited - Power : Programme 2: Free Unknown #1'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Free Unknown 1'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Unlimited - Power: Programme 3: Free Unknown #2"' do
      description = 'Unlimited - Power: Programme 3: Free Unknown #2'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Free Unknown 2'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Unlimited - Glider : Programme 1: Free Known"' do
      description = 'Unlimited - Glider : Programme 1: Free Known'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Known'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Unlimited - Glider : 1st Unknown Sequence"' do
      description = 'Unlimited - Glider : 1st Unknown Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Unknown 1'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Unlimited - Glider : 2nd Unknown Sequence"' do
      description = 'Unlimited - Glider : 2nd Unknown Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Unknown 2'
      expect(detect_flight_category(description)).to eq 'Unlimited'
    end

    it 'gets "Advanced - Glider : Free Known Sequence"' do
      description = 'Advanced - Glider : Free Known Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Known'
      expect(detect_flight_category(description)).to eq 'Advanced'
    end

    it 'gets "Advanced - Glider : 1st Unknown Sequence"' do
      description = 'Advanced - Glider : 1st Unknown Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Unknown 1'
      expect(detect_flight_category(description)).to eq 'Advanced'
    end

    it 'gets "Advanced - Glider : 2nd Unknown Sequence"' do
      description = 'Advanced - Glider : 2nd Unknown Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Free Unknown 2'
      expect(detect_flight_category(description)).to eq 'Advanced'
    end

    it 'gets "Advanced - Power : Free Unknown Sequence"' do
      description = 'Advanced - Power : Free Unknown Sequence'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Free Unknown'
      expect(detect_flight_category(description)).to eq 'Advanced'
    end

    it 'gets "Primary : Programme 1: Free Known"' do
      description = 'Primary : Programme 1: Free Known'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 1'
      expect(detect_flight_category(description)).to eq 'Primary'
    end

    it 'gets "Sportsman Power : Programme 1: Known"' do
      description = 'Sportsman Power : Programme 1: Known'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Known'
      expect(detect_flight_category(description)).to eq 'Sportsman'
    end

    it 'gets "Intermediate - Glider : Known Sequence"' do
      description = 'Intermediate - Glider : Known Sequence'
      expect(detect_flight_aircat(description)).to eq 'G'
      expect(detect_flight_name(description)).to eq 'Known'
      expect(detect_flight_category(description)).to eq 'Intermediate'
    end

    it 'gets "Sportsman - Power : Known Sequence"' do
      description = 'Sportsman - Power : Known Sequence'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Known'
      expect(detect_flight_category(description)).to eq 'Sportsman'
    end

    it 'gets "Primary - Power : Known Sequence"' do
      description = 'Primary - Power : Known Sequence'
      expect(detect_flight_aircat(description)).to eq 'P'
      expect(detect_flight_name(description)).to eq 'Flight 1'
      expect(detect_flight_category(description)).to eq 'Primary'
    end


  end
end
