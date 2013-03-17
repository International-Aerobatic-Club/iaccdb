class FlightsController < ApplicationController

  # GET /flights/1
  # GET /flights/1.xml
  def show
    @flight = Flight.find(params[:id])
    @f_result = @flight.f_results.first
    if @f_result
      @pf_results = @f_result.pf_results.order(:adj_flight_rank)
      @judge_results = {}
      @pf_results.each do |pf_result|
        @judge_results[pf_result] = pf_result.pilot_flight.pfj_results.order(:judge_id)
      end
      @jf_results = @f_result.jf_results.order(:judge_id)
    else
      @pilot_flights = @flight.pilot_flights
    end

    respond_to do |format|
      format.html do
        if @f_result
          render :show
        else
          render :raw, :notice => "Results unavailable"
        end
      end
      format.xml  { render :xml => @flight }
    end
  end

end
