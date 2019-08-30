module MakeModelsHelper
  def make_or_unspecified(make)
    make.blank? ? "{no make specified}" : make
  end

  def model_or_unspecified(model)
    model.blank? ? "{no model specified}" : model
  end
end
