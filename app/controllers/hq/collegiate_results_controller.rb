module Hq

  class CollegiateResultsController < ApplicationController
    # GET /hq/collegiates/:year
    # GET /hq/collegiates.json/:year
    def index
      year_setup(params)
      @teams = CollegiateResult.where(:year => @year)

      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @teams }
      end
    end

    # GET /hq/collegiates/1
    # GET /hq/collegiates/1.json
    def show
      @team = CollegiateResult.find(params[:id])

      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @team }
      end
    end

    # GET /hq/collegiates/:year/new
    # GET /hq/collegiates/:year/new.json
    def new
      year_setup(params)
      @team = CollegiateResult.new(:year => @year)

      respond_to do |format|
        format.html # new.html.erb
        format.json { render json: @team }
      end
    end

    # GET /hq/collegiates/1/edit
    def edit
      @team = CollegiateResult.find(params[:id])
    end

    # POST /hq/collegiates
    # POST /hq/collegiates.json
    def create
      @team = CollegiateResult.new(collegiate_result_params)

      respond_to do |format|
        if @team.save
          format.html { redirect_to hq_collegiate_teams_index_path(@team.year), notice: 'Collegiate team successfully created.' }
          format.json { render json: hq_collegiate_teams_index_path(@team.year), status: :created, location: @team }
        else
          format.html { render action: "new" }
          format.json { render json: @team.errors, status: :unprocessable_entity }
        end
      end
    end

    # PUT /hq/collegiates/1
    # PUT /hq/collegiates/1.json
    def update
      @team = CollegiateResult.find(params[:id])

      respond_to do |format|
        if @team.update_attributes(collegiate_result_params)
          format.html { redirect_to hq_collegiate_path, notice: 'Collegiate team successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @team.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /hq/collegiates/1
    # DELETE /hq/collegiates/1.json
    def destroy
      @team = CollegiateResult.find(params[:id])
      if @team
        year = @team.year
        @team.destroy
      end

      respond_to do |format|
        format.html { redirect_to year ?
          hq_collegiate_teams_index_url(year) : hq_current_collegiate_teams_url }
        format.json { head :no_content }
      end
    end


    def recompute

      IAC::CollegiateComputer.new(params[:year]&.to_i).recompute

      respond_to do |format|
        format.html { redirect_to leaders_collegiate_path, notice: 'Collegiate results successfully recalculated.' }
        format.json { head :no_content }
      end

    end


    ###
    private
    ###

    def year_setup(params)
      @years = CollegiateResult.select(:year).distinct.order(year: :desc).pluck(:year)
      @year = params[:year] || @years.first || Time.now.year
    end

    def collegiate_result_params
      params.require(:collegiate_result).permit(
        :name, :year,
        members_attributes: [ :id, :iac_id, :family_name, :given_name, :_destroy ]
      )
    end

  end

end
