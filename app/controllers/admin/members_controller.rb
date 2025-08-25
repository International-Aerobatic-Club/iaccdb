class Admin::MembersController < ApplicationController
  before_action :authenticate

  def index
    @members = Member.where.not(family_name: ['', nil], given_name: ['', nil]).order(:family_name, :given_name).all
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
    if @member.update(member_params)
      redirect_to admin_members_path(:anchor => @member.id),
        :notice => "Member updated"
    else
      render :action => "edit"
    end
  end

  def merge_preview
    selected = merge_params.fetch('selected', {}).keys
    if 1 < selected.count
      merge = MemberMerge::Merge.new(selected)
      if !merge.has_multiple_members
        flash[:alert] = 'select multiple members to merge'
        redirect_to admin_members_url
      else
        @role_flights = merge.role_flights
        @target = merge.default_target
        @members = merge.members

        if (merge.has_collisions)
          flash[:alert] =
            'Data will be lost.  ' +
            'Some of the selected members have the same role in the same flight.'
          @collisions = merge.flight_collisions
        else
          @collisions = nil
        end

        if (merge.has_overlaps)
          flash[:notice] =
            'Some selected members have different roles on the same flight.'
          @overlaps = merge.flight_overlaps
        else
          @overlaps = nil
        end
      end
    else
      flash[:alert] = 'select two or more members to merge'
      redirect_to admin_members_url
    end
  end

  def merge
    @target = Member.find(params[:target])
    if @target
      merge = MemberMerge::Merge.new(params[:selected].keys)
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

  def member_params
    params.require('member').permit(['iac_id', 'given_name', 'family_name'])
  end

  def merge_params
    nested_keys = params.fetch(:selected, {}).keys
    params.permit(:selected => nested_keys)
  end

  def check_dups_join(accum, list)
    if !(accum & list).empty?
      flash[:alert] = "Selected members participated together"
    end
    accum + list
  end
end
