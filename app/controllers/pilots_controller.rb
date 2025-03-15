class PilotsController < ApplicationController
  def index
    # Joining with `pilot_flights` acts as a filter to select only those Members who have competed
    @pilots = Member.joins(:pilot_flights).order(:family_name, :given_name).distinct
  end

  def show
    id = params[:id]
    @pilot = Member.find(id)
    @contests =
      Contest.joins(pc_results: :category)
             .where(pc_results: { pilot_id: id })
             .order(start: :desc)
             .select('contests.*, categories.name as category')
             .distinct
  end
end
