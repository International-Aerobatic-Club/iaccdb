# process db flights to identify hors_concours

module Jasper
class HorsConcoursParticipants
  attr_accessor :contest

  def initialize(contest)
    @contest = contest
  end

  def mark_solo_participants_as_hc
    flights = @contest.flights
    flights_by_cat = flights.group_by { |f| f.category_id }
    flights_by_cat.each_key do |cat|
      # working a category
      # cat_flights is an array of flights in this category
      cat_flights = flights_by_cat[cat]
      # participant_counts is an array of counts:
      #  - the number of pilot_flights in each flight of this category
      #  is equivalent to the number of pilots participating in each flight
      participant_counts = cat_flights.collect { |f| f.pilot_flights.count }
      max_ct = participant_counts.inject(0) do |max_ct, ct|
        max_ct < ct ? ct : max_ct
      end
      if 1 == max_ct
        cat_flights.each do |f|
          f.pilot_flights.each do |pf|  ### there ought to be only one
            pf.hors_concours = true
            pf.save!
          end
        end
      end
    end
  end

  def mark_lower_category_participants_as_hc
    flights = @contest.flights
    pilot_flights = PilotFlight.where(flight_id: flights.collect(&:id))
    cats_by_pilot = {}
    pilot_flights.each do |pf|
      cats_by_pilot[pf.pilot] ||= []
      cats_by_pilot[pf.pilot] << pf.category
    end
    cats_by_pilot.each_pair do |pilot, pilot_cats|
      cats = pilot_cats.uniq
      grouped_cats = cats.group_by { |cat| cat.aircat }
      grouped_cats.each_value do |comp_cats|
        if 1 < comp_cats.count
          mark_lower_cats_for_pilot(pilot, comp_cats)
        end
      end
    end
  end

  #######
  private
  #######

  def mark_lower_cats_for_pilot(pilot, cats)
    cats = cats.sort do |a,b|
      a.sequence <=> b.sequence
    end
    cat_flights = @contest.flights.where(
      category_id: cats[0...-1].collect(&:id))
    pilot_flights = PilotFlight.where(flight_id: cat_flights.collect(&:id),
      pilot_id: pilot.id)
    pilot_flights.each do |pf| 
      pf.hors_concours = true
      pf.save!
    end
  end

end
end

