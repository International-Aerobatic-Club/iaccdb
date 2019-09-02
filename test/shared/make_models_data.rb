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
    create_list(:airplane, Random.rand(7) + 4)
    MakeModel.all.each do |mm|
      create_list(:airplane, Random.rand(7) + 2, make_model: mm)
    end
    MakeModel.all.to_a
  end

  def admin_make_models_select_params(select_models, target = nil)
    params = {
      "selected" => select_models.inject(Hash.new) do |hash, mm|
        hash[mm.id.to_s] = "1"
        hash
      end
    }
    params = params.merge({ target.id.to_s => 'merge' }) if target
    params
  end
end
