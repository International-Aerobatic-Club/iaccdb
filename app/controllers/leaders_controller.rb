class LeadersController < ApplicationController
  def judges
    @max_displayed = 50
    @years = JyResult.select("distinct year").all.collect { |jy_result| jy_result.year }
    @years.sort!{|a,b| b <=> a}
    @year = params[:year] || @years.first
    jy_results = JyResult.includes(:category, :judge).select(
      [:pilot_count, :sigma_ri_delta, :con, :dis, :minority_zero_ct,
       :minority_grade_ct, :pair_count, :ftsdx2, :ftsdy2, :ftsdxdy, :sigma_d2,
       :total_k, :figure_count, :flight_count, :ri_total].collect { |col|
      "sum(#{col}) as #{col}" }.join(',') + ", judge_id,
      category_id").where(["year = ?", @year]).group( :judge_id, :category_id)
    cat_results = jy_results.group_by { |jy_result| jy_result.category }
    crop_results = {}
    cat_results.each do |cat, jy_results|
      jy_results.sort! { |b,a| (a.con - a.dis) <=> (b.con - b.dis) }
      crop_results[cat] = jy_results.first(@max_displayed)
    end
    @results = crop_results.sort_by { |cat, jy_results| cat.sequence }
  end

  def pilots
  end

  def regionals
    @years = RegionalPilot.select("distinct year").all.collect{|rp| rp.year}.sort{|a,b| b <=> a}
    @year = params[:year] || @years.first
    region_pilots = RegionalPilot.includes(:category, :pilot, :pc_results).joins(:region_contest).where(['year = ?', @year]).group('regional_pilot_id').having('count(distinct pc_result_id) > 1')
    sorted_regions = {}
    @region_categories = {}
    region_results = region_pilots.group_by { |rp| rp.region }
    region_results.each do |region, rp|
      cat_results = rp.group_by { |rpc| rpc.category }
      cat_results.each do |cat, rpc|
        puts "Category #{cat} region #{region} has region_pilots: #{rpc}"
        rpc.sort! { |a,b| a.rank <=> b.rank }
      end
      sorted_regions[region] = cat_results.sort_by { |cat, rpc| cat.sequence }
      @region_categories[region] = cat_results.keys.sort_by { |cat| cat.sequence }
    end
    @results = sorted_regions.sort
    @regions = sorted_regions.keys.sort
  end

  def soucy
    @years = SoucyResult.select("distinct year").all.collect{|rp| rp.year}.sort{|a,b| b <=> a}
    @year = params[:year] || @years.first
    @soucies = SoucyResult.includes(:pc_results).where("year = ?", @year
      ).order(qualified: :desc, rank: :asc).limit(10)
    @nationals = Contest.where("year(start) = ? and region = 'National'", @year).first
  end


  def leo

    @years = Time.now.year.downto(2021).to_a
    @year = params[:year] || @years.first

    # !!! !!! !!! !!! !!! !!! !!! !!! !!!
    # Un-comment the following line to force a recomputation with every GET request (useful for debugging via IDE)
    # IAC::LeoComputer.new(@year).recompute
    # !!! !!! !!! !!! !!! !!! !!! !!! !!!

    @leo_ranks = LeoRank.where(year: @year)
    @leo_pilot_contests = LeoPilotContest.where(year: @year).order(:region, points: :desc)

    # !!! HACK !!!
    # LeoComputer saves the `contest#id` value in the `name` attr
    @contests = Contest.where(id: LeoPilotContest.where(year: @year).distinct.pluck(:name)).map do |contest|
      [ contest.id.to_s, contest ]
    end.to_h

  end


  def collegiate
    @years = CollegiateResult.distinct(:year).order(year: :desc).pluck(:year)
    @year = params[:year] || @years.first
    @collegiates = CollegiateResult.includes(:pc_results).where(year: @year).order(qualified: :desc, rank: :asc)
    i_results = CollegiateIndividualResult.where(year: @year).order(qualified: :desc, rank: :asc)
    # hash of pilot to pilot's collegiate individual result
    @college_pilots = {}
    @collegiates.each do |cr|
      @college_pilots[cr] = i_results.where(pilot: cr.members).sort_by{ |r| -r.points }
    end
  end


  def pilot_contest_counts

    # Global var to hold the year
    @year = nil

    # Well need this value, probably
    this_year = Time.now.year

    if params[:year].present?

      if params[:year].casecmp('all') == 0
        cids = Contest.pluck(:id)
        @year = "2006-#{this_year}"
      else
        @year = params[:year].to_i
        if @year < 2006 || @year > this_year
          flash[:alert] = "Invalid year: #{@year}, using #{this_year} instead"
          @year = this_year
        end
        cids = Contest.where('YEAR(start) = ?', @year)
      end

    else
      # params[:year] is not present; default to the current year
      cids = Contest.where('YEAR(start) = ?', this_year).pluck(:id)
      @year = this_year
    end

    # Cache the list of all flights for the selected contests
    flights = Flight.where(contest_id: cids)

    # Hash of Pilot ID (key) and IDs of contest IDs
    @pilot_contests = Hash.new

    # For each PilotFlight, add the Contest.id value to the pilot's array
    PilotFlight.where(flight_id: flights.pluck(:id)).each do |pf|
      @pilot_contests[pf.pilot_id] ||= Array.new
      @pilot_contests[pf.pilot_id] << pf.flight.contest_id
    end

    # Replace the list of contest IDs with the count of unique contest IDs
    @pilot_contests.each{ |k,v| @pilot_contests[k] = v.uniq.count }

  end


end
