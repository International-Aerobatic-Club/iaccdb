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
      role_flights = merge.role_flights
      @chief_flights = role_flights[:chief_judge]
      @assist_chief_flights = role_flights[:assist_chief_judge]
      @judge_flights = role_flights[:line_judge]
      @assist_flights = role_flights[:assist_line_judge]
      @competitor_flights = role_flights[:competitor]
      @target = merge.default_target
      @members = merge.members

      if (merge.has_collisions)
        flash[:alert] = 
          'Data will be lost.  ' +
          'Some of the selected members have the same role in the same flight.'
      end
      @collisions = merge.flight_collisions

      if (merge.has_overlaps)
        flash[:notice] = 
          'Some selected members have different roles on the same flight.  ' +
          'Chief and line judge is probably okay.  ' +
          'Pilot and judge is probably not okay.'
      end
      @overlaps = merge.flight_overlaps
    end
  end

  def merge
    @target = Member.find(params[:target])
    if @target
      merge = MemberMerge.new(params[:selected].keys)
      merge.execute_merge(@target)
      flash[:notice] = "Members merged into #{@target.name}"
      redirect_to admin_members_path(:anchor => @target.id)
    else
      flash[:alert] = "No target member selected"
      redirect_to merge_preview_path
    end
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
