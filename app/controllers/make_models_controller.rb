class MakeModelsController < ApplicationController
  def index
    @make_models = MakeModel.all_by_make
  end

  def show
    @make_model = MakeModel.find(params[:id])
  end
end
