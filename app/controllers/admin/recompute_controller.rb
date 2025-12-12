# frozen_string_literal: true

class Admin::RecomputeController < Admin::AdminController

  before_action :get_list_of_years
  before_action :get_award_options

  def index
  end


  def update

    errors = []
    errors << 'Please select a year to recompute.' if params[:year].blank?
    errors << 'Please select an award to recompute.' if params[:award].blank?
    return render :index, locals: { alert: errors.join('<br>') } if errors.any?

    year = params[:year].to_i

    case params[:award]
    when 'all'
      recompute_collegiate(year)
      recompute_leo(year)
      recompute_regional(year)
      recompute_soucy(year)
    when 'collegiate'
      recompute_collegiate(year)
    when 'leo'
      recompute_leo(year)
    when 'regional'
      recompute_regional(year)
    when 'soucy'
      recompute_soucy(year)
    else
      raise "Unknown award #{params[:award]}"
    end

    respond_to do |format|
      format.html { redirect_to admin_recompute_path, notice: 'Recomputation(s) complete.' }
      format.json { head :no_content }
    end

  end


  private

  def recompute_collegiate(year)
    Iac::CollegiateComputer.new(year).recompute
  end


  def recompute_soucy(year)
    Iac::SoucyComputer.new(year).recompute
  end


  def recompute_regional(year)
    Iac::SoucyComputer.new(year).recompute
  end


  def recompute_leo(year)
    Iac::LeoComputer.new(year).recompute
  end


  def get_list_of_years
    @years = Contest.select('YEAR(start) AS yr').distinct.order(yr: :desc).map(&:yr)
  end


  def get_award_options
    @award_options = [
      ['-- Select One --', nil],
      ['All Awards', :all],
      ['Collegiate', :collegiate],
      ['National Point Series (Leo)', :leo],
      ['Regional Point Series', :regional],
      ['Soucy', :soucy],
    ]
  end

end
