class MakeModelsController < ApplicationController
  def index
    @make_models = MakeModel.all
  end

  def show
  end
end
