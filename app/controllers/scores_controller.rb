class ScoresController < ApplicationController

  # GET pilot/:pilot_id/scores/:contest_id
  def show
    @contest = Contest.find(params[:id])
    @pilot = Member.find(params[:pilot_id])
    @pilot_flights = PilotFlight.joins(:flight).where(
       {:pilot_flights => {pilot_id: @pilot},
        :flights => {contest_id: @contest}}
      ).order("flights.sequence")
  end

end
