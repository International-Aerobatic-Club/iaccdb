require 'spec_helper'

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
      expect(detect_flight_aircat('Four')).to eq 'P'
      expect(detect_flight_aircat('Minute')).to eq 'P'
      expect(detect_flight_aircat('Primary')).to eq 'P'
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

  end
end
