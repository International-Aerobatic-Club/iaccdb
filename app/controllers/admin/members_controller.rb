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
    merge = MemberMerge.new(params[:selected].keys)
    if !merge.has_multiple_members
      flash[:alert] = 'select multiple members to merge'
      redirect_to admin_members_url 
    else
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
      @target = @members.first.id
      if (merge.has_collisions)
        flash[:alert] = 'Data will be lost.  Some of the selected members participated together in the same flight.'
      end
      @collisions = merge.collisions
    end
  end

  def merge
    tgt = [params[:target]]
    ids = params[:selected].keys - tgt
    @target = Member.find(tgt).first
    @target.merge_members(ids)
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
