class Admin::PilotContestCountsController < ApplicationController

  before_action :authenticate

  # GET /admin/pilot_contest_counts
  def index

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
