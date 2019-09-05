class MakeModelsController < ApplicationController
  def index
    only_curated = request.format.symbol == :json
    @make_models = MakeModel.all_by_make(only_curated)
  end

  def show
    @make_model = MakeModel.find(params[:id])
  end
end
