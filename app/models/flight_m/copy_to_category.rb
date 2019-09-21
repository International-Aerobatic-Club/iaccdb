module FlightM
  module CopyToCategory
    def copy_to_category(category)
      new_attrs = self.attributes
      new_attrs.delete('id')
      new_attrs.delete('category_id')
      new_attrs['category_id'] = category.id
      flight = Flight.find_by(contest_id: self.contest_id,
        name: self.name, category_id: category.id)
      if (flight)
        flight.update!(new_attrs)
      else
        new_attrs['category_id'] = category.id
        flight = Flight.create!(new_attrs)
      end
      copy_pilot_flights_to(flight)
      flight
    end

    def copy_pilot_flights_to(flight)
      new_pilots = self.pilot_flights.collect(&:pilot_id)
      prior_pilots = flight.pilot_flights.collect(&:pilot_id)
      flight.pilot_flights.where(
        pilot_id: prior_pilots - new_pilots
      ).each do |pf|
        flight.pilot_flights.delete(pf)
      end
      self.pilot_flights.each do |pf|
        pf.extend(PilotFlightM::CopyToFlight)
        pf.copy_to_flight(flight)
      end
    end
  end
end
