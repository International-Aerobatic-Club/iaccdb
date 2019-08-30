require "test_helper"

module MakeModelsData
  def setup_make_models_data
    mmods = build_list :make_model, Random::rand(4) + 2
    mmods.collect(&:make).uniq.inject(Hash.new) do |memo, make|
      memo[make] = create_list(:make_model, Random::rand(5) + 1, make: make)
      memo
    end
  end
end
