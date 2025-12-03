# Mix this into a Contest record to collect results on it
module Contest::ShowResults
  # given array of flight records,
  # return a possibly empty array of unique chief judge names
  def flights_chiefs(cfs)
    cfs.map(&:chief).compact.uniq.sort_by(&:family_name).map(&:name)
  end

  def chief_names
    flights_chiefs(flights.all)
  end

  def is_future
    Time.now < start + 2.days
  end

  def place_and_time
    "#{is_future ? 'Scheduled' : 'Held'} in #{place}, #{start}"
  end

  def organizers
    orgs = []
    orgs << "Director: #{director}" if director
    orgs << "Chapter #{chapter}" if chapter&.positive?
    orgs.join(', ')
  end

  #   category_results: array of category_data in category sort order
  #     category_data {}
  #       cat: Category record
  #       chiefs: array of chief judge member names
  #       judge_results: array of JcResult records in no particular order
  #       flights: array of Flight data records in flight.sequence order
  #       pilot_results: array of pilot results for category
  #            in order ascending overall rank
  #         pilot_result {}
  #           member: Member record for the pilot
  #           overall: PcResult for pilot in contest and category
  #           airplane: description of airplane from one pilot_flight
  #           chapter: chapter number from one pilot_flight
  #           flight_results: hash of flight results for pilot
  #             key is Flight, value is array of PfResult (with one element)
  def category_results
    categories = []
    unless flights.empty?
      cats = flights.map(&:categories)
      cats = cats.flatten.uniq.sort { |a,b| a.sequence <=> b.sequence }
      cats.each do |cat|
        category_data = {}
        category_data[:cat] = cat
        category_data[:judge_results] = jc_results.where(category: cat).includes(:judge)
        category_data[:flights] = cat.flights.where(contest: self).all.sort_by(&:sequence)
        category_data[:chiefs] = flights_chiefs(category_data[:flights])
        category_data[:pilot_results] = []
        pcrs = pc_results.where(category: cat).includes(:pilot).order(:category_rank)
        unless pcrs.empty?
          pf_results = PfResult.joins(pilot_flight: :flight).where(flights: { id: flights.map(&:id) })
          pfr_by_flight = pf_results.all.group_by(&:flight)
          pfr_by_flight.each_key do |flight|
            pfr_by_flight[flight] = PfResultM::HcRanked.computed_display_ranks(pfr_by_flight[flight])
          end
          pcrs = PcResultM::HcRanked.computed_display_ranks(pcrs.all)
          pcrs.each do |p|
            pilot_result = {}
            pilot_result[:member] = p.pilot
            pilot_result[:overall] = p
            pilot_result[:flight_results] = {}
            fr = {}
            pf_results = []

            pfr_by_flight.each_key do |flight|
              fr[flight] = pfr_by_flight[flight].find_all{ |f| f.pilot_flight.pilot_id == p.pilot_id }
              if fr[flight].empty?
                fr[flight] = nil
              else
                pf_results << fr[flight].first
              end
            end

            pilot_result[:flight_results] = fr
            pfr = pf_results.first
            pf = pfr.pilot_flight if pfr
            if (pf)
              pilot_result[:airplane] = pf.airplane
              pilot_result[:chapter] = pf.chapter
            else
              pilot_result[:airplane] = nil
              pilot_result[:chapter] = ''
            end
            category_data[:pilot_results] << pilot_result
          end
        end
        categories << category_data
      end
    end
    categories
  end
end
