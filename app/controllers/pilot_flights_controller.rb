class PilotFlightsController < ApplicationController
  def show
    @pilot_flight = PilotFlight.find(params[:id])
  end
end
