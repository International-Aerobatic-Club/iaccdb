class Admin::MakeModelsController < ApplicationController
  before_action :authorize_curator

  def index
    @make_models = MakeModel.all.order(:make, :model)
  end

  def show
    load_mm
  end

  def edit
    load_mm
  end

  def update
    load_mm.update_attributes(mm_params)
  end

  def merge_preview
    selected = merge_params.fetch('selected', {}).keys
    if 1 < selected.count
      # TODO render preview
      return head :not_found
    else
      flash[:alert] = 'select two or more make and model to merge'
      redirect_to admin_make_models_url
    end
  end

  #######
  private
  #######

  def load_mm
    @make_model ||= MakeModel.find(params[:id])
  end

  def mm_params
    params.require(:make_model).permit(
      :make, :model,
      :empty_weight_lbs, :max_weight_lbs,
      :horsepower, :seats, :wings
    )
  end

  def merge_params
    nested_keys = params.fetch(:selected, {}).keys
    params.permit(:selected => nested_keys)
  end

  def authorize_curator
    authenticate(:curator)
  end
end
