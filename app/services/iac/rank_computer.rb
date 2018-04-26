# assume loaded with rails ActiveRecord
# environment for IAC contest data application
# for PfResult and PfjResult classes

# this class contains methods to compute rankings from results.
# It derives rankings from the scores, ranking pilots from highest
# to lowest score.
# It completes rank information for the individual pilot-judge-figure
# grades.
module IAC
  class RankComputer
    include Singleton
    include Log::ConfigLogger

    def computeJudgeMetrics(flight)
      jf_results_by_judge = {}
      p_ranks = []
      j_rank_for_jf = {}
      # compute ranks and calculations based on individual rank
      flight.pilot_flights.each do |pilot_flight|
        logger.info "Computing ranks and judge metrics for #{pilot_flight}"
        pf_result = pilot_flight.pf_results.first
        if pf_result
          p = pf_result.flight_rank || 0
          p_ranks << p
          pilot_flight.pfj_results.each do |pfj_result|
            logger.debug "Incorporating #{pfj_result}"
            judge = pfj_result.judge
            jf_result = jf_results_by_judge[judge]
            if !jf_result
              jf_result = 
                flight.jf_results.where(:judge_id => judge.id).first ||
                flight.jf_results.create(:judge => judge)
              jf_result.zero_reset
              j_rank_for_jf[jf_result] = []
              jf_results_by_judge[judge] = jf_result
            end
            jf_result.pilot_count += 1
            jf_result.total_k += pilot_flight.sequence.total_k
            jf_result.figure_count += pilot_flight.sequence.figure_count
            j = pfj_result.flight_rank || 0
            j_rank_for_jf[jf_result] << j
            jf_result.sigma_ri_delta += (j - p).abs *
              (pfj_result.flight_value.fdiv(10) - pf_result.flight_value).abs / 
              pf_result.flight_value if 0 < pf_result.flight_value
            pfj_result.computed_values.each_with_index do |computed, i|
              graded = pfj_result.graded_values[i]
              jf_result.minority_zero_ct += 1 if graded == Constants::HARD_ZERO && 0 < computed 
              jf_result.minority_grade_ct += 1 if computed < graded
            end
            logger.debug "Updated jf_result #{jf_result}"
          end
        end
      end
      # now do the calculations we couldn't do before we had all of the
      # ranks
      avg_p_ranks = average_ranks(p_ranks)
      pilot_count = p_ranks.length
      avg_rank = (pilot_count + 1) / 2.0
      jf_results_by_judge.each do |judge, jf_result|
        logger.debug "Computing ranks for #{jf_result}"
        j_ranks = j_rank_for_jf[jf_result]
        avg_j_ranks = average_ranks(j_ranks)
        (0 ... pilot_count).each do |ip|
          # values for rho
          ap = avg_p_ranks[ip] || 0
          aj = avg_j_ranks[ip] || 0
          p = ap - avg_rank
          j = aj - avg_rank
          jf_result.ftsdxdy += 4 * j * p
          jf_result.ftsdx2 += 4 * j * j
          jf_result.ftsdy2 += 4 * p * p
          p_rank = p_ranks[ip] || 0
          j_rank = j_ranks[ip] || 0
          d = p_rank - j_rank
          jf_result.sigma_d2 += d * d
          # concordant and discordant counts
          (ip+1 ... pilot_count).each do |jp|
            jip = j_ranks[ip] || 0
            jjp = j_ranks[jp] || 0
            pip = p_ranks[ip] || 0
            pjp = p_ranks[jp] || 0
            if (jip < jjp && pip < pjp) ||
               (jip > jjp && pip > pjp)
              jf_result.con += 1
            elsif (jip < jjp && pip > pjp) ||
                  (jip > jjp && pip < pjp)
              jf_result.dis += 1
            end
          end
        end
        jf_result.flight_count += 1
        jf_result.pair_count = pilot_count * (pilot_count - 1) / 2
        jf_result.ri_total = calc_ri(jf_result.sigma_ri_delta, pilot_count)
        jf_result.save
        logger.debug "Computed jf_result ranks #{jf_result}"
      end
      jf_results_by_judge.values
    end

    # Compute result values for one flight of the contest
    # Accepts a flight
    # Creates or updates pfj_result, pf_result
    # Does no computation if there are no sequence figure k values 
    # Does figure computations if all fly the same sequence
    # Returns the array of pf_results
    def computeFlight(flight, has_soft_zero)
      seq = nil
      same = true
      flight.pilot_flights.each do |pilot_flight|
        seq ||= pilot_flight.sequence
        same &&= seq != nil && seq == pilot_flight.sequence
      end
      if seq
        flight.pilot_flights.each do |pilot_flight|
          sac = SaComputer.new(pilot_flight)
          sac.computePilotFlight(has_soft_zero)
        end
        pf_results = computeFlightOverallRankings(flight)
        computeFlightFigureRankings(flight, pf_results) if same
      else
        pf_results = []
      end
      pf_results
    end

    # Recompute rankings of pilots given existing results
    # Accepts a flight
    # Does no result computations, only computes the rankings
    def compute_flight_rankings(flight)
      computeFlightOverallRankings(flight)
    end

    # Compute rankings of Result given array of Result
    # Ranks non-qualified results after qualified results
    # Save each one after computation
    def self.compute_result_rankings(results)
      qualifiers = results.select { |result| result.qualified }
      percentages = qualifiers.collect { |result| result.result_percent } 
      rankings = Ranking::Computer.ranks_for(percentages)
      qualifiers.each_with_index do |result,i|
        result.rank = rankings[i]
        result.save!
      end
      qual_count = qualifiers.size
      non_quals = results - qualifiers
      percentages = non_quals.collect { |result| result.result_percent }
      rankings = Ranking::Computer.ranks_for(percentages)
      non_quals.each_with_index do |result,i|
        result.rank = qual_count + rankings[i]
        result.save!
      end
    end

    # set the value of ranked[i].display_rank based on
    # the value of ranked[i].hors_concours and ranked[i].rank
    # ranked is an array
    def compute_rankings_with_hc(ranked)
      r = Array.new(ranked.length, 1)
      (0 ... ranked.length).each do |i|
        (i + 1 ... ranked.length).each do |j|
          if (ranked[i] && ranked[j])
            r[i] += 1 if ranked[i].rank > ranked[j].rank && !ranked[j].hors_concours
            r[j] += 1 if ranked[j].rank > ranked[i].rank && !ranked[i].hors_concours
          end
        end
      end
      ranked.each_with_index do |t,i|
        if t.hors_concours
          t.display_rank = 'HC'
        else
          t.display_rank = r[i].to_s
        end
      end
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
    def computeFlightOverallRankings(flight)
      logger.info "Computing rankings for #{flight}"
      pf_results = []
      flight_values = []
      adjusted_flight_values = []
      judge_pilot_flight_values = {} #flight_values lookup by judge
      flight.pilot_flights.each do |pilot_flight|
        pf_result = pilot_flight.pf_results.first
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
        logger.debug "Computing figure rankings for #{pf_result.to_s}" 
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
