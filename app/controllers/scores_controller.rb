class ScoresController < ApplicationController

  # GET pilot/:pilot_id/scores/:contest_id
  def show
    @contest = Contest.find(params[:id])
    @pilot = Member.find(params[:pilot_id])
    @pilot_flights = PilotFlight.find_by_sql(["select p.* 
      from pilot_flights p, flights f 
      where f.contest_id = :cid and p.flight_id = f.id and p.pilot_id = :pid
      order by f.sequence", {:cid => params[:id], :pid => params[:pilot_id]}])
    @flight_scores = []
    @pilot_flights.each do |pf|
      @flight_scores << pf.gatherScores
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @pilot_flights }
    end
  end

  # GET /scores/new
  # GET /scores/new.xml
  def new
    @score = Score.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @score }
    end
  end

  # GET /scores/1/edit
  def edit
    @score = Score.find(params[:id])
  end

  # POST /scores
  # POST /scores.xml
  def create
    @score = Score.new(params[:score])

    respond_to do |format|
      if @score.save
        format.html { redirect_to(@score, :notice => 'Score was successfully created.') }
        format.xml  { render :xml => @score, :status => :created, :location => @score }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /scores/1
  # PUT /scores/1.xml
  def update
    @score = Score.find(params[:id])

    respond_to do |format|
      if @score.update_attributes(params[:score])
        format.html { redirect_to(@score, :notice => 'Score was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /scores/1
  # DELETE /scores/1.xml
  def destroy
    @score = Score.find(params[:id])
    @score.destroy

    respond_to do |format|
      format.html { redirect_to(scores_url) }
      format.xml  { head :ok }
    end
  end
end
