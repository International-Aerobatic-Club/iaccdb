class AssociateMakeModels < ActiveRecord::Migration
  def up
    MakeModelService.associate_airplane_make_models
  end
end
