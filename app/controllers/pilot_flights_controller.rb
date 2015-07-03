class PilotFlightsController < ApplicationController
  before_action :authenticate, :except => [index, show]
  
  # GET /pilot_flights
  # GET /pilot_flights.xml
  def index
    @pilot_flights = PilotFlight.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pilot_flights }
    end
  end

  # GET /pilot_flights/1
  # GET /pilot_flights/1.xml
  def show
    @pilot_flight = PilotFlight.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pilot_flight }
    end
  end

  # GET /pilot_flights/new
  # GET /pilot_flights/new.xml
  def new
    @pilot_flight = PilotFlight.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @pilot_flight }
    end
  end

  # GET /pilot_flights/1/edit
  def edit
    @pilot_flight = PilotFlight.find(params[:id])
  end

  # POST /pilot_flights
  # POST /pilot_flights.xml
  def create
    @pilot_flight = PilotFlight.new(params[:pilot_flight])

    respond_to do |format|
      if @pilot_flight.save
        format.html { redirect_to(@pilot_flight, :notice => 'Pilot flight was successfully created.') }
        format.xml  { render :xml => @pilot_flight, :status => :created, :location => @pilot_flight }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @pilot_flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /pilot_flights/1
  # PUT /pilot_flights/1.xml
  def update
    @pilot_flight = PilotFlight.find(params[:id])

    respond_to do |format|
      if @pilot_flight.update_attributes(params[:pilot_flight])
        format.html { redirect_to(@pilot_flight, :notice => 'Pilot flight was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @pilot_flight.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /pilot_flights/1
  # DELETE /pilot_flights/1.xml
  def destroy
    @pilot_flight = PilotFlight.find(params[:id])
    @pilot_flight.destroy

    respond_to do |format|
      format.html { redirect_to(pilot_flights_url) }
      format.xml  { head :ok }
    end
  end
end
