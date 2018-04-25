class Admin::MakeModelsController < ApplicationController
  before_filter :authorize_curator

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

  def authorize_curator
    authenticate(:curator)
  end
end
