require 'test_helper'
require 'shared/make_models_data'
require 'shared/json_headers'

class MakeModelsController::IndexJsonAllTest < ActionDispatch::IntegrationTest
  include MakeModelsData
  include JsonHeaders

  setup do
    @mmods = setup_make_models_data
    @expected_make_models = @mmods.values.flatten
    get make_models_url, headers: json_headers, params: { include_all: true }
    @data = @response.parsed_body
  end

  test 'json includes makes and models not curated' do
    makes = @data['airplane_makes']
    make_models = makes.collect do |make|
      make_models = make['airplane_models']
      make_models
    end
    returned_names = make_models.flatten.collect do |mm|
      "#{mm['make']}, #{mm['model']}"
    end
    expected_names = @expected_make_models.collect do |mm|
      "#{mm.make}, #{mm.model}"
    end
    assert_equal(expected_names.sort, returned_names.sort)
  end
end
