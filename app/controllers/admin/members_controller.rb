class Admin::MembersController < ApplicationController
  before_filter :authenticate

  def index
    @members = Member.order(:family_name, :given_name)
  end

  def show
    @member = Member.includes(:chief, :assistChief, :flights, :judge, :assist).find(params[:id])
    @chief_flights = @member.chief
    @assist_chief_flights = @member.assistChief
    @judge_flights = @member.judge_flights
    @assist_flights = @member.assist_flights
    @competitor_flights = @member.flights
  end

  def edit
    @member = Member.find(params[:id])
  end

  def update
    @member = Member.find(params[:id])
    if @member.update_attributes(params[:member])
      redirect_to admin_members_path(:anchor => @member.id),
        :notice => "Member updated"
    else
      render :action => "edit"
    end
  end

  def merge_preview
    @members = Member.find(params[:selected].keys)
    if @members.length == 1
      flash[:alert] = 'select multiple members to merge'
      redirect_to admin_members_url 
    else
      @target = @members.first.id
      @chief_flights = @members.inject([]) do |flights, member|
        check_dups_join(flights, member.chief) 
      end
      @assist_chief_flights = @members.inject([]) do |flights, member|
        check_dups_join(flights, member.assistChief) 
      end
      @judge_flights = @members.inject([]) do |flights, member|
        check_dups_join(flights, member.judge_flights) 
      end
      @assist_flights = @members.inject([]) do |flights, member|
        check_dups_join(flights, member.assist_flights) 
      end
      @competitor_flights = @members.inject([]) do |flights, member|
        check_dups_join(flights, member.flights) 
      end
    end
  end

  def merge
    tgt = [params[:target]]
    ids = params[:selected].keys - tgt
    @target = Member.find(tgt).first
    @members = Member.find(ids)
    PilotFlight.update_all(['pilot_id = ?', @target.id], 
      ['pilot_id in (?)', ids.join(',')])
    Judge.update_all(['judge_id = ?', @target.id], 
      ['judge_id in (?)', ids.join(',')])
    Judge.update_all(['assist_id = ?', @target.id], 
      ['assist_id in (?)', ids.join(',')])
    Flight.update_all(['chief_id = ?', @target.id], 
      ['chief_id in (?)', ids.join(',')])
    Flight.update_all(['assist_id = ?', @target.id], 
      ['assist_id in (?)', ids.join(',')])
    PcResult.update_all(['pilot_id = ?', @target.id], 
      ['pilot_id in (?)', ids.join(',')])
    JcResult.update_all(['judge_id = ?', @target.id], 
      ['judge_id in (?)', ids.join(',')])
    JyResult.update_all(['judge_id = ?', @target.id], 
      ['judge_id in (?)', ids.join(',')])
    @members.each { |member| member.destroy }
    flash[:notice] = "Members merged into #{@target.name}"
    redirect_to admin_members_path(:anchor => @target.id)
  end

  ###
  private
  ###

  def check_dups_join(accum, list)
    if !(accum & list).empty?
      flash[:alert] = "Selected members participated together"
    end
    accum + list
  end
end
