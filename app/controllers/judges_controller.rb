class JudgesController < ApplicationController
  # GET /judges
  # GET /judges.xml
  def index
    @judges = Judge.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @judges }
    end
  end

  # GET /judges/1
  # GET /judges/1.xml
  def show
    @judge = Judge.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @judge }
    end
  end

  # GET /judges/new
  # GET /judges/new.xml
  def new
    @judge = Judge.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @judge }
    end
  end

  # GET /judges/1/edit
  def edit
    @judge = Judge.find(params[:id])
  end

  # POST /judges
  # POST /judges.xml
  def create
    @judge = Judge.new(params[:judge])

    respond_to do |format|
      if @judge.save
        format.html { redirect_to(@judge, :notice => 'Judge was successfully created.') }
        format.xml  { render :xml => @judge, :status => :created, :location => @judge }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /judges/1
  # PUT /judges/1.xml
  def update
    @judge = Judge.find(params[:id])

    respond_to do |format|
      if @judge.update_attributes(params[:judge])
        format.html { redirect_to(@judge, :notice => 'Judge was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /judges/1
  # DELETE /judges/1.xml
  def destroy
    @judge = Judge.find(params[:id])
    @judge.destroy

    respond_to do |format|
      format.html { redirect_to(judges_url) }
      format.xml  { head :ok }
    end
  end
end
