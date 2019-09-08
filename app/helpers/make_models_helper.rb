module MakeModelsHelper
  def make_or_unspecified(make)
    make.blank? ? "{no make specified}" : make
  end

  def model_or_unspecified(model)
    model.blank? ? "{no model specified}" : model
  end

  def make_model_wings(mm)
    number = (mm.wings == nil || mm.wings < 1 || 2 < mm.wings) ? 0 : mm.wings
    [nil, 'monoplane', 'biplane'][number]
  end

  def make_model_horsepower(mm)
    (mm.horsepower && 0 < mm.horsepower) ? "#{mm.horsepower}hp" : nil
  end

  def make_model_seats(mm)
    (mm.seats && 0 < mm.seats) ? pluralize(mm.seats, "seat") : nil
  end

  def make_model_curated(mm)
    mm.curated ? '👍 ' : ''
  end

  def make_model_description(mm)
    [
      make_model_curated(mm) + make_or_unspecified(mm.make),
      model_or_unspecified(mm.model),
      make_model_horsepower(mm),
      make_model_wings(mm),
      make_model_seats(mm)
    ].compact.join(', ')
  end

  def model_description(mm)
    [
      make_model_curated(mm) + model_or_unspecified(mm.model),
      make_model_horsepower(mm),
      make_model_wings(mm),
      make_model_seats(mm)
    ].compact.join(', ')
  end
end
