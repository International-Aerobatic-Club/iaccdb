# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

#require 'ranking/computer'
#require 'log/config_logger'

# this class contains methods to compute rankings from results.
# It derives rankings from the scores, ranking pilots from highest
# to lowest score.
# It completes rank information for the individual pilot-judge-figure
# grades.
module IAC
  class RankComputer
    include Singleton
    include Log::ConfigLogger
    cattr_accessor :logger

    HARD_ZERO = -30
    
    def computeJudgeMetrics(flight, f_result)
      jf_results_by_judge = {}
      p_ranks = []
      j_rank_for_jf = {}
      # compute ranks and calculations based on individual rank
      flight.pilot_flights.each do |pilot_flight|
        logger.info "Computing ranks and judge metrics for #{pilot_flight}"
        pf_result = pilot_flight.pf_results.first
        if pf_result
          p = pf_result.flight_rank
          p_ranks << p
          pilot_flight.pfj_results.each do |pfj_result|
            logger.info "Computing #{pfj_result}"
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
            jf_result.total_k += pilot_flight.sequence.total_k
            jf_result.figure_count += pilot_flight.sequence.figure_count
            j = pfj_result.flight_rank
            j_rank_for_jf[jf_result] << j
            jf_result.sigma_ri_delta += (j - p).abs *
              (pfj_result.flight_value.fdiv(10) - pf_result.flight_value).abs / 
              pf_result.flight_value if 0 < pf_result.flight_value
            pfj_result.computed_values.each_with_index do |computed, i|
              graded = pfj_result.graded_values[i]
              jf_result.minority_zero_ct += 1 if graded == HARD_ZERO && 0 < computed 
              jf_result.minority_grade_ct += 1 if computed < graded
            end
          end
        end
      end
      # now do the calculations we couldn't do before we had all of the
      # ranks
      avg_p_ranks = average_ranks(p_ranks)
      pilot_count = p_ranks.length
      avg_rank = (pilot_count + 1) / 2.0
      jf_results_by_judge.each do |judge, jf_result|
        logger.info "Computing ranks for #{jf_result}"
        j_ranks = j_rank_for_jf[jf_result]
        avg_j_ranks = average_ranks(j_ranks)
        (0 ... pilot_count).each do |ip|
          # values for rho
          p = avg_p_ranks[ip] - avg_rank
          j = avg_j_ranks[ip] - avg_rank
          jf_result.ftsdxdy += 4 * j * p
          jf_result.ftsdx2 += 4 * j * j
          jf_result.ftsdy2 += 4 * p * p
          d = p_ranks[ip] - j_ranks[ip]
          jf_result.sigma_d2 += d * d
          # concordant and discordant counts
          (ip+1 ... pilot_count).each do |jp|
            if (j_ranks[ip] < j_ranks[jp] && p_ranks[ip] < p_ranks[jp]) ||
               (j_ranks[ip] > j_ranks[jp] && p_ranks[ip] > p_ranks[jp])
              jf_result.con += 1
            elsif (j_ranks[ip] < j_ranks[jp] && p_ranks[ip] > p_ranks[jp]) ||
                  (j_ranks[ip] > j_ranks[jp] && p_ranks[ip] < p_ranks[jp])
              jf_result.dis += 1
            end
          end
        end
        jf_result.flight_count += 1
        jf_result.pair_count = pilot_count * (pilot_count - 1) / 2
        jf_result.ri_total = calc_ri(jf_result.sigma_ri_delta, pilot_count)
        jf_result.save
      end
      jf_results_by_judge.values
    end

    # Compute rank for each pilot in a contest category
    def computeCategory(c_result)
      logger.info "Computing ranks for #{c_result}"
      category_values = []
      c_result.pc_results.each do |pc_result|
        category_values << pc_result.category_value
      end
      begin
        category_ranks = Ranking::Computer.ranks_for(category_values)
        c_result.pc_results.each_with_index do |pc_result, i|
          pc_result.category_rank = category_ranks[i]
          pc_result.save
        end
      rescue Exception => exception
        logger.error exception.message
        contest = c_result.contest
        Failure.create(
          :step => "category",
          :contest_id => contest.id,
          :manny_id => contest.manny_synch ? contest.manny_synch.manny_number : nil,
          :description => 
            ":: category #{c_result} contest id #{c_result.contest.id}" +
            "\n:: category_values " + category_values.to_yaml +
            "\n:: #{exception.message} ::\n" + exception.backtrace.join("\n"))
      end
      c_result
    end

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Does the figure computations only if all fly the same sequence
    # Returns the array of pf_results
    def computeFlight(flight, has_soft_zero)
      seq = nil
      same = true
      flight.pilot_flights.each do |pilot_flight|
        seq ||= pilot_flight.sequence
        same &&= seq != nil && seq == pilot_flight.sequence
      end
      if seq
        pf_results = computeFlightOverallRankings(flight, has_soft_zero)
        computeFlightFigureRankings(flight, pf_results) if same
      else
        pf_results = []
      end
      pf_results
    end

  ###
  private
  ###

    # scale sigma_ri_delta using pilot count to get CIVA ri value
    def calc_ri(sigma_ri_delta, pilot_count)
      if pilot_count && pilot_count != 0
        (20.0 * sigma_ri_delta) / 
          (0.0057 * pilot_count * pilot_count + 0.1041 * pilot_count)
      else
        0
      end
    end

    # Convert raw ranks (number of better pilots + 1) into
    # average ranks, in which tied pilots have rank equal to
    # the average of the positions they would hold.
    # Average ranks are decimal values, not integers
    # This is for the Spearman corellation coefficient (rho) computation
    def average_ranks(ranks)
      sorted_ranks = ranks.sort
      rank_conv = []
      w = 0
      v = sorted_ranks[0]
      (1 .. ranks.length).each do |r|
        if r == ranks.length || sorted_ranks[r] != v
          v += (r - w - 1) / 2.0
          while w < r do
            rank_conv << v
            w += 1
          end
          v = sorted_ranks[r]
        end
      end
      avg_ranks = []
      (0 ... ranks.length).each do |r|
        avg_ranks << rank_conv[ranks[r]-1]
      end
      avg_ranks
    end

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Returns the flight
    def computeFlightOverallRankings(flight, has_soft_zero)
      logger.info "Computing rankings for #{flight}"
      pf_results = []
      flight_values = []
      adjusted_flight_values = []
      judge_pilot_flight_values = {} #flight_values lookup by judge
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.results(has_soft_zero)
        pf_result.judge_teams.each do |judge|
          if (!judge_pilot_flight_values[judge])
            judge_pilot_flight_values[judge] = Array.new
          end
          pfj_result = pf_result.for_judge(judge)
          judge_pilot_flight_values[judge] << pfj_result.flight_value
        end
        flight_values << pf_result.flight_value
        adjusted_flight_values << pf_result.adj_flight_value
        pf_results << pf_result
      end
      begin
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
      rescue Exception => exception
        logger.error "Error computing rankings for flight #{flight} is #{exception.message}"
        contest = flight.contest
        Failure.create(
          :step => 'flight_ranks',
          :contest_id => contest.id,
          :manny_id => contest.manny_synch ? contest.manny_synch.manny_number : nil,
          :description => 
            ":: Flight #{flight} " +
            "\n:: flight_values " + flight_values.to_yaml +
            "\n:: judge_pilot_flight_values " +
            judge_pilot_flight_values.to_yaml +
            "\n:: #{exception.message} ::\n" + exception.backtrace.join("\n"))
      end
      pf_results
    end

    # Compute by-figure result values for pf_results of one flight of the contest
    # Accepts flight pf_results
    # Creates or updates pfj_result, pf_result
    # Do not call unless all pilot_flight have same sequence
    def computeFlightFigureRankings(flight, pf_results)
      logger.info "Computing figure rankings for #{flight}"
      judge_pilot_figure_computed_values = {} #computed_values lookup by judge
      judge_pilot_figure_graded_values = {} #graded_values lookup by judge
      pilot_figure_results = [] # figure results from each pilot
      pf_results.each do |pf_result|
        logger.info "Computing figure rankings for #{pf_result.to_s}" 
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
          # treat HZ as zero for purposes of rank computation
          graded_values = pfj_result.graded_values.map { |g| g < 0 ? 0 : g }
          pilot_figure_graded_values << graded_values
          judge_pilot_figure_graded_values[judge] =
            pilot_figure_graded_values
        end
        pilot_figure_results << pf_result.figure_results
      end
      judge_pilot_figure_computed_ranks = {}
      judge_pilot_figure_graded_ranks = {}
      begin
        judge_pilot_figure_computed_values.each_key do |judge|
          judge_pilot_figure_computed_ranks[judge] =
            Ranking::Computer.rank_matrix(judge_pilot_figure_computed_values[judge])
          judge_pilot_figure_graded_ranks[judge] =
            Ranking::Computer.rank_matrix(judge_pilot_figure_graded_values[judge])
        end
        pilot_figure_ranks =
          Ranking::Computer.rank_matrix(pilot_figure_results)
        pf_results.each_with_index do |pf_result, i|
          pf_result.judge_teams.each do |judge|
            pfj_result = pf_result.for_judge(judge)
            pfj_result.computed_ranks = judge_pilot_figure_computed_ranks[judge][i]
            pfj_result.graded_ranks = judge_pilot_figure_graded_ranks[judge][i]
            pfj_result.save
          end
          pf_result.figure_ranks = pilot_figure_ranks[i]
          pf_result.save
        end
      rescue Exception => exception
        logger.error exception.message
        contest = flight.contest
        Failure.create(
          :step => "figures",
          :contest_id => contest.id,
          :manny_id => contest.manny_synch ? contest.manny_synch.manny_number : nil,
          :description => 
            ":: flight #{flight} \n:: judge_pilot_figure_computed_values " +
            judge_pilot_figure_computed_values.to_yaml + 
            "\n:: judge_pilot_figure_graded_values " +
            judge_pilot_figure_graded_values.to_yaml + 
            "\n:: #{exception.message} ::\n" + 
            exception.backtrace.join("\n"))
      end
    end
  end # class
end # module
