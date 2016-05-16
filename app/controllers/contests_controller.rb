class ContestsController < ApplicationController

  # GET /contests
  def index
    @years = Contest.select("distinct year(start) as anum").all.collect { |contest| contest.anum }
    @years.sort!{|a,b| b <=> a}
    @year = params[:year] || @years.first
    @contests = Contest.where('year(start) = ?', @year).order("start DESC")
  end

  # GET /contests/1
  #   @contest: Contest data record
  #   @categories: array of category_data in category sort order
  #     category_data {}
  #       cat: Category record
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
  def show
    @contest = Contest.find(params[:id])
    flights = @contest.flights
    @categories = []
    if !flights.empty?
      cats = flights.collect { |f| f.category }
      cats = cats.uniq.sort { |a,b| a.sequence <=> b.sequence }
      cats.each do |cat|
        category_data = {}
        category_data[:cat] = cat
        category_data[:judge_results] = JcResult.where(
          contest: @contest, category: cat).includes(:judge)
        category_data[:flights] = Flight.where(contest: @contest,
          category: cat).all
        category_data[:pilot_results] = []
        pc_results = PcResult.where(contest: @contest, category:cat).includes(
          :pilot).order(:category_rank)
        if !pc_results.empty?
          pf_results = PfResult.joins({:pilot_flight => :flight}).where(
             {:flights => {contest_id: @contest, category_id: cat}})
          pfr_by_flight = pf_results.all.group_by do |pf|
            pf.flight
          end
          pfr_by_flight.each_key do |flight|
            pfr_by_flight[flight] = PfResultM::HcRanked.computed_display_ranks(
              pfr_by_flight[flight])
          end
          pc_results =
            PcResultM::HcRanked.computed_display_ranks(pc_results.all)
          pc_results.each do |p|
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
        @categories << category_data
      end
    end
    render :show
  end

end
