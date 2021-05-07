class ScoresController < ApplicationController
  # GET pilot/:pilot_id/scores/:contest_id
  def show
    @contest = Contest.find(params[:id])
    @pilot = Member.find(params[:pilot_id])
    @pilot_flights = PilotFlight.includes(:flight => :categories).where(
       {:pilot_flights => {pilot_id: @pilot}, :flights => {contest_id: @contest}}
      ).order(Category.arel_table[:sequence], Flight.arel_table[:sequence])
  end
end
