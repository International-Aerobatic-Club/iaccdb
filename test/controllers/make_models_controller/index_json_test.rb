require 'test_helper'
require 'shared/make_models_data'
require 'shared/json_headers'

# JSON returns as follows, formatting added,
#   elipses represent hash elements repeated within an array
# {
#   "airplane_makes": [
#     {
#       "make": "Discovery",
#       "airplane_models": [
#         {
#           "model": "Allan Hills 84001",
#           "empty_weight_lbs": 783,
#           "max_weight_lbs": 1251,
#           "horsepower": 545,
#           "seats": 2,
#           "wings": 1
#         },
#         ...
#         {
#           "model": "Stannern",
#           "empty_weight_lbs": 1065,
#           "max_weight_lbs": 1614,
#           "horsepower": 155,
#           "seats": 4,
#           "wings": 2
#         }
#       ]
#     },
#     ...
#     {
#       "make": "Mercury",
#       "airplane_models": [
#         ...
#       ]
#     }
#   ]
# }
class MakeModelsController::IndexJsonTest < ActionDispatch::IntegrationTest
  include MakeModelsData
  include JsonHeaders

  setup do
    @mmods = setup_make_models_data
    @expected_make_models = @mmods.values.flatten.select do |mm|
      mm.curated
    end
    get make_models_url, headers: json_headers
    @data = @response.parsed_body
  end

  test 'json has makes' do
    assert_equal(["airplane_makes"], @data.keys)
    airplane_makes = @data["airplane_makes"]
    assert_equal(%w[airplane_models make], airplane_makes.first.keys.sort)
    makes = airplane_makes.collect { |airplane| airplane["make"] }
    expected_makes = @expected_make_models.collect(&:make).uniq
    assert_equal(expected_makes.sort, makes.sort)
  end

  test 'json has models for make' do
    airplane_makes = @data["airplane_makes"]
    airplane_models = airplane_makes.first["airplane_models"]
    first_make = airplane_makes.first["make"]
    expected_models = @expected_make_models.select do |mm|
      mm.make == first_make
    end
    airplane_model_names = airplane_models.collect do |airplane|
      airplane["model"]
    end
    expected_model_names = expected_models.collect do |airplane|
      airplane["model"]
    end
    assert_equal(expected_model_names.sort, airplane_model_names.sort)
  end

  test 'json has airplane make model details' do
    make = @mmods.keys.first
    expected_airplane = @mmods[make].first
    airplane_makes = @data['airplane_makes']
    make_models = airplane_makes.select do |airplane_make|
      airplane_make["make"] == make
    end
    make_model = make_models.first['airplane_models'].select do |airplane_model|
      airplane_model["model"] == expected_airplane.model
    end
    airplane = make_model.first
    %w[make model empty_weight_lbs max_weight_lbs horsepower
        seats wings curated].each do |attrib|
      assert_equal(expected_airplane.send(attrib), airplane[attrib])
    end
  end

  test 'json only includes curated makes and models' do
    makes = @data['airplane_makes']
    makes.each do |make|
      make_models = make['airplane_models']
      make_models.each do |model|
        assert(model['curated'])
      end
    end
  end
end
