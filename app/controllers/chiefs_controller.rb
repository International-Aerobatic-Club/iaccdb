class ChiefsController < ApplicationController

  def index
    @chiefs = Member.where(
      id: Flight.where.not(chief_id: nil).distinct(:chief_id).pluck(:chief_id)
    ).order(:family_name, :given_name)
  end

  def cv

    @chief = Member.find(params[:id])
    @contests = Contest.where(id: Flight.where(chief_id: @chief.id).distinct(:contest_id).pluck(:contest_id)).order(start: :desc)

    @flight_counts = Array.new

    @career = Hash.new

    @contests.each do |contest|

      @flight_counts[contest.id] = Hash.new

      contest.flights.each do |flight|
        cat_id = flight.category.id
        @flight_counts[contest.id][cat_id] ||= 0
        @flight_counts[contest.id][cat_id] += flight.pilot_flights.count
        @career[cat_id] ||= 0
        @career[cat_id] += flight.pilot_flights.count
      end

    end

  end

end
