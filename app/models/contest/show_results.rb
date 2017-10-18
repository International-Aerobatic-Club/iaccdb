# Mix this into a Contest record to collect results on it
module Contest::ShowResults
  # given array of flight records,
  # return possibly empty array of unique chief judge names
  def flights_chiefs(cfs)
    chiefs = []
    unless cfs.empty?
      cjs = cfs.collect do |flight|
        flight.chief
      end
      cjs = cjs.compact.uniq.sort do |a,b|
        a.family_name <=> b.family_name
      end
      chiefs = cjs.collect(&:name)
    end
    chiefs
  end

  def chief_names
    flights_chiefs(flights.all)
  end

  def organizers
    orgs = []
    orgs << "Directed by #{director}" if director
    orgs << "Chapter #{chapter}" if chapter != nil && 0 < chapter
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
    if !flights.empty?
      cats = flights.collect { |f| f.category }
      cats = cats.uniq.sort { |a,b| a.sequence <=> b.sequence }
      cats.each do |cat|
        category_data = {}
        category_data[:cat] = cat
        category_data[:judge_results] = jc_results.where(
          category: cat).includes(:judge)
        category_data[:flights] = flights.where(
          category: cat).all.sort { |a,b| a.sequence <=> b.sequence }
        category_data[:chiefs] = flights_chiefs(category_data[:flights])
        category_data[:pilot_results] = []
        pcrs = pc_results.where(category:cat).includes(:pilot).order(:category_rank)
        if !pcrs.empty?
          pf_results = PfResult.joins({:pilot_flight => :flight}).where(
             {:flights => {contest_id: id, category_id: cat}})
          pfr_by_flight = pf_results.all.group_by do |pf|
            pf.flight
          end
          pfr_by_flight.each_key do |flight|
            pfr_by_flight[flight] = PfResultM::HcRanked.computed_display_ranks(
              pfr_by_flight[flight])
          end
          pcrs =
            PcResultM::HcRanked.computed_display_ranks(pcrs.all)
          pcrs.each do |p|
            pilot_result = {}
            pilot_result[:member] = p.pilot
            pilot_result[:overall] = p
            pilot_result[:flight_results] = {}
            fr = {}
            pf_results = []
            pfr_by_flight.each_key do |flight|
              fr[flight] = pfr_by_flight[flight].select do |f|
                f.pilot_flight.pilot == p.pilot
              end
              if (fr[flight].empty?)
                fr[flight] = nil
              else
                pf_results << fr[flight]
              end
            end
            pilot_result[:flight_results] = fr
            pfr = pf_results.flatten.first
            pf = pfr.pilot_flight if pfr
            if (pf)
              pilot_result[:airplane] = pf.airplane
              pilot_result[:chapter] = pf.chapter
            else
              pilot_result[:airplane] = null
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

