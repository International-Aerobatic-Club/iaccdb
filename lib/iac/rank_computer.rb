# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

require 'ranking/computer.rb'

# this class contains methods to compute rankings from results.
# It derives rankings from the scores, ranking pilots from highest
# to lowest score.
# It completes rank information for the individual pilot-judge-figure
# grades.
module IAC
  class RankComputer

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Does figure computations only if all fly the same sequence
    # Returns the flight
    def self.computeFlight(flight)
      seq = nil
      same = false
      flight.pilot_flights.each do |pilot_flight|
        seq ||= pilot_flight.sequence
        same = seq != nil && seq == pilot_flight.sequence
      end
      computeFlightOverallRankings(flight) if seq
      computeFlightFigureRankings(flight) if same
    end

  ###
  private
  ###

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Returns the flight
    def self.computeFlightOverallRankings(flight)
      pf_results = []
      flight_values = []
      adjusted_flight_values = []
      judge_pilot_flight_values = {} #flight_values lookup by judge
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.results
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
          pilot_flight_values = 
            judge_pilot_flight_values[judge] || Array.new
          pilot_flight_values << pfj_result.flight_value
          judge_pilot_flight_values[judge] = pilot_flight_values
        end
        flight_values << pf_result.flight_value
        adjusted_flight_values << pf_result.adj_flight_value
        pf_results << pf_result
      end
      flight_ranks = Ranking::Computer.ranks_for(flight_values)
      adjusted_flight_ranks = Ranking::Computer.ranks_for(adjusted_flight_values)
      judge_pilot_flight_ranks = {}
      judge_pilot_flight_values.each_key do |judge|
        judge_pilot_flight_ranks[judge] =
          Ranking::Computer.ranks_for(judge_pilot_flight_values[judge])
      end
      pf_results.each_with_index do |pf_result, i|
        pf_result.flight_rank = flight_ranks[i]
        pf_result.adj_flight_rank = adjusted_flight_ranks[i]
        pf_result.save
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
          pfj_result.flight_rank = judge_pilot_flight_ranks[judge][i]
          pfj_result.save
        end
      end
      flight
    end

    # Compute by-figure result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Do not call unless all pilot_flight have same sequence
    # Returns the flight
    def self.computeFlightFigureRankings(flight)
      pf_results = []
      judge_pilot_figure_computed_values = {} #computed_values lookup by judge
      judge_pilot_figure_graded_values = {} #graded_values lookup by judge
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.results
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
          # computed value matrix
          pilot_figure_computed_values = 
            judge_pilot_figure_computed_values[judge] || Array.new
          pilot_figure_computed_values << pfj_result.computed_values
          judge_pilot_figure_computed_values[judge] =
            pilot_figure_computed_values
          # graded value matrix
          pilot_figure_graded_values = 
            judge_pilot_figure_graded_values[judge] || Array.new
          pilot_figure_graded_values << pfj_result.graded_values
          judge_pilot_figure_graded_values[judge] =
            pilot_figure_graded_values
        end
        pf_results << pf_result
      end
      judge_pilot_figure_computed_ranks = {}
      judge_pilot_figure_graded_ranks = {}
      judge_pilot_figure_computed_values.each_key do |judge|
        judge_pilot_figure_computed_ranks[judge] =
          Ranking::Computer.rank_matrix(judge_pilot_figure_computed_values[judge])
        judge_pilot_figure_graded_ranks[judge] =
          Ranking::Computer.rank_matrix(judge_pilot_figure_graded_values[judge])
      end
      pf_results.each_with_index do |pf_result, i|
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
          pfj_result.computed_ranks = judge_pilot_figure_computed_ranks[judge][i]
          pfj_result.graded_ranks = judge_pilot_figure_graded_ranks[judge][i]
          pfj_result.save
        end
      end
      flight
    end

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Returns the flight
    def self.old_computeFlight(flight)
      pf_results = []
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.results
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
        end
        pf_results << pf_result
      end
      pf_results.each do |pf_result|
      end
      pf_results.each_with_index do |pf_result, i|
        pf_result.save
        pf_result.judge_teams.each do |judge|
          pfj_result = pf_result.for_judge(judge)
          pfj_result.save
        end
      end
      flight
    end

  end # class
end # module
