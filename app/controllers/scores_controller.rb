class ScoresController < ApplicationController

  # GET pilot/:pilot_id/scores/:contest_id
  def show
    @contest = Contest.find(params[:id])
    @pilot = Member.find(params[:pilot_id])
    @pilot_flights = PilotFlight.joins(:flight => :category).where(
       {:pilot_flights => {pilot_id: @pilot},
        :flights => {contest_id: @contest}}
      ).order("categories.sequence, flights.sequence")
  end

end
