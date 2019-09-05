require 'test_helper'
require 'shared/make_models_data'

class MakeModel::AllByMakeTest < ActiveSupport::TestCase
  include MakeModelsData

  setup do
    @make_models_data = setup_make_models_data
  end

  test 'groups by make' do
    mmods = MakeModel.all_by_make
    assert_equal(@make_models_data.keys.sort, mmods.keys.sort)
  end

  test 'includes MakeModel records for each make' do
    mmods = MakeModel.all_by_make
    @make_models_data.each_key do |make|
      models = mmods.fetch(make, nil)
      refute_nil(models)
      expected_models = @make_models_data[make]
      expected_model_names = expected_models.collect(&:model).sort
      model_names = models.collect(&:model).sort
      assert_equal(expected_model_names, model_names)
      expected_model_empty_weights =
        expected_models.collect(&:empty_weight_lbs).sort
      empty_weights = models.collect(&:empty_weight_lbs).sort
      assert_equal(expected_model_empty_weights, empty_weights)
    end
  end

  test 'includes only curated MakeModel records when requested' do
    mmods = MakeModel.all_by_make(true)
    mmods.each_key do |make|
      models = mmods.fetch(make, nil)
      refute_nil(models)
      curated_flags = models.collect(&:curated).uniq
      assert_equal([true], curated_flags)
    end
  end
end
