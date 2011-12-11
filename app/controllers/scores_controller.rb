class ScoresController < ApplicationController

  # GET pilot/:pilot_id/scores/:contest_id
  def show
    @contest = Contest.find(params[:id])
    @pilot = Member.find(params[:pilot_id])
    @pilot_flights = PilotFlight.find_by_sql(["select p.* 
      from pilot_flights p, flights f 
      where f.contest_id = :cid and p.flight_id = f.id and p.pilot_id = :pid
      order by f.sequence", {:cid => params[:id], :pid => params[:pilot_id]}])
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pilot_flights }
    end
  end

end
