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
      expect(detect_flight_name('Flight #1')).to eq 'Flight 1'
      expect(detect_flight_name('Flight #2')).to eq 'Flight 2'
      expect(detect_flight_name('1st Flight')).to eq 'Flight 1'
      expect(detect_flight_name('2nd Flight')).to eq 'Flight 2'
      expect(detect_flight_name('3rd Flight')).to eq 'Flight 3'
      expect(detect_flight_name('Flight #3')).to eq 'Flight 3'
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

  end
end
