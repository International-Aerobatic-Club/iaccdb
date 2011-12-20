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

    def self.computeJudgeMetrics(flight, f_result)
      jf_results_by_judge = {}
      p_ranks = []
      j_rank_for_jf = {}
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.pf_results.first
        p = pf_result.flight_rank
        p_ranks << p
        pilot_flight.pfj_results.each do |pfj_result|
          judge = pfj_result.judge
          jf_result = jf_results_by_judge[judge]
          if !jf_result
            jf_result = 
              f_result.jf_results.first(:conditions => {
                :judge_id => judge}) ||
              f_result.jf_results.build(:judge => judge)
            jf_result.zero_reset
            j_rank_for_jf[jf_result] = []
            jf_results_by_judge[judge] = jf_result
          end
          jf_result.pilot_count += 1
          j = pfj_result.flight_rank
          j_rank_for_jf[jf_result] << j
          d = p - j
          jf_result.sigma_d2 += d * d
          jf_result.sigma_pj += p * j
          jf_result.sigma_p2 += p * p
          jf_result.sigma_j2 += j * j
          jf_result.sigma_ri_delta += (j - p).abs *
            (pfj_result.flight_value.fdiv(10) - pf_result.flight_value).abs / 
            pf_result.flight_value
          pfj_result.computed_values.each_with_index do |computed, i|
            graded = pfj_result.graded_values[i]
            jf_result.minority_zero_ct += 1 if graded < computed
            jf_result.minority_grade_ct += 1 if computed < graded
          end
        end
      end
      jf_results_by_judge.each do |judge, jf_result|
        aj = j_rank_for_jf[jf_result]
        (0 ... p_ranks.length).each do |ip|
          (ip+1 ... p_ranks.length).each do |jp|
            if (aj[ip] < aj[jp] && p_ranks[ip] < p_ranks[jp]) ||
               (aj[ip] > aj[jp] && p_ranks[ip] > p_ranks[jp])
              jf_result.con += 1
            elsif (aj[ip] < aj[jp] && p_ranks[ip] > p_ranks[jp]) ||
               (aj[ip] > aj[jp] && p_ranks[ip] < p_ranks[jp])
              jf_result.dis += 1
            end
          end
        end
        jf_result.save
      end
      jf_results_by_judge.values
    end

    # Compute rank for each pilot in a contest category
    def self.computeCategory(c_result)
      category_values = []
      c_result.pc_results.each do |pc_result|
        category_values << pc_result.category_value
      end
      category_ranks = Ranking::Computer.ranks_for(category_values)
      c_result.pc_results.each_with_index do |pc_result, i|
        pc_result.category_rank = category_ranks[i]
        pc_result.save
      end
      c_result
    end

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Does figure computations only if all fly the same sequence
    # Returns the array af pf_results
    def self.computeFlight(flight)
      pf_results = []
      seq = nil
      same = false
      flight.pilot_flights.each do |pilot_flight|
        seq ||= pilot_flight.sequence
        same = seq != nil && seq == pilot_flight.sequence
      end
      pf_results = computeFlightOverallRankings(flight) if seq
      computeFlightFigureRankings(flight) if same
      pf_results
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
      pf_results
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
  end # class
end # module
