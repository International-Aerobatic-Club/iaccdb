class FlightsController < ApplicationController

  # GET /flights/1
  # GET /flights/1.xml
  def show
    @flight = Flight.find(params[:id])
    @pf_results = PfResult.joins(:pilot_flight).where(
      ['pilot_flights.flight_id = ?', @flight.id]).order(:adj_flight_rank)
    @judge_results = {}
    @pf_results.each do |pf_result|
      @judge_results[pf_result] = pf_result.pilot_flight.pfj_results.order(:judge_id)
    end
    @jf_results = @flight.jf_results.order(:judge_id)

    respond_to do |format|
      format.html { render :show }
      format.xml  { render :xml => @flight }
    end
  end

end
