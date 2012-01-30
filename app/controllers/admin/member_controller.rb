class Admin::MemberController < ApplicationController
  before_filter :authenticate

  def index
    @members = Member.order(:family_name, :given_name)
  end

  def show
    @member = Member.includes(:chief, :assistChief, :flights, :judge, :assist).find(params[:id])

    @judge_flights = Set.new
    @member.judge.each do |judge|
      flights = []
      judge.pilot_flights.each do |pilot_flight|
        flights << pilot_flight.flight
      end
      @judge_flights |= flights
    end
    @judge_flights -= [nil]

    @assist_flights = Set.new
    @member.assist.each do |judge|
      flights = []
      judge.pilot_flights.each do |pilot_flight|
        flights << pilot_flight.flight
      end
      @assist_flights |= flights
    end
    @assist_flights -= [nil]
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end

  def merge_preview
  end

  def merge
  end

end
