# process db flights to identify hors_concours

module IAC
  class HorsConcoursParticipants
    attr_accessor :contest

    def initialize(contest)
      @contest = contest
    end

    def mark_solo_participants_as_hc
      flights = @contest.flights
      categories = flights.collect do |f|
        f.categories.all
      end
      categories = categories.flatten.uniq
      flights_by_cat = {}
      flights.each do |f|
        f.categories.each do |cat|
          flights_by_cat[cat] ||= []
          flights_by_cat[cat] << f
        end
      end
      categories.each do |cat|
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
              pf.hc_no_competition.save!
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
        pf.categories.where(synthetic: false).each do |cat|
          cats_by_pilot[pf.pilot] << cat
        end
      end
      cats_by_pilot.each_pair do |pilot, pilot_cats|
        grouped_cats = pilot_cats.uniq.group_by { |cat| cat.aircat }
        grouped_cats.each_value do |comp_cats|
          if 1 < comp_cats.count
            mark_lower_cats_for_pilot(pilot, comp_cats)
          end
        end
      end
    end

    def mark_pc_results_based_on_flights
      pcrs = PcResult.where(contest_id: contest.id)
      pcrs.each do |pcr|
        pcr.clear_hc
        cat = pcr.category
        flights = cat.flights.where(contest_id: contest.id)
        PilotFlight.where(flight: flights, pilot_id: pcr.pilot_id).each do |pf|
          pcr.hors_concours |= pf.hors_concours
        end
        pcr.save!
      end
    end

    #######
    private
    #######

    def mark_lower_cats_for_pilot(pilot, cats)
      cats = cats.sort do |a,b|
        a.sequence <=> b.sequence
      end
      cat_flight_ids = cats[0...-1].collect do |cat|
        cat.flights.where(contest: @contest).pluck(:id)
      end
      cat_flight_ids = cat_flight_ids.flatten.uniq
      pilot_flights = PilotFlight.where(flight_id: cat_flight_ids,
        pilot_id: pilot.id)
      pilot_flights.each do |pf| 
        pf.hc_higher_category.save!
      end
    end

  end
end
