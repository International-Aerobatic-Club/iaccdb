require "test_helper"

module MakeModelsData
  def setup_make_models_data
    mmods = build_list :make_model, Random::rand(4) + 2
    mmods.collect(&:make).uniq.inject(Hash.new) do |memo, make|
      memo[make] = create_list(:make_model, Random::rand(5) + 1, make: make)
      memo
    end
  end

  def setup_make_models_with_airplanes
    create_list(:airplane, Random.rand(7) + 8)
    MakeModel.all.each do |mm|
      create_list(:airplane, Random.rand(7) + 2, make_model: mm)
    end
    MakeModel.all.to_a
  end

  def select_models_for_merge(models)
    select = [models.first, models.last]
    4.times do
      select << models[Random.rand(models.length)]
    end
    select.uniq
  end
end
