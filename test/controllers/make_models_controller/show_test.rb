require 'test_helper'
require 'shared/make_models_data'

# markup like this:
# <h1>S1T</h1>
# <dl class="make-model">
#   <dt>Make</dt><dd>Pitts</dd>
#   <dt>Model</dt><dd>S1T</dd>
#   <dt>Empty weight</dt><dd>780 lbs</dd>
#   ...
# <dl>
class MakeModelsController::ShowTest < ActionDispatch::IntegrationTest
  test 'show view' do
    mm = create(:make_model)
    get make_model_url(mm)
    assert_response :success
    assert_select('h1', mm.model)
    assert_select('dl.make-model', 1)
    %w[Make Model Empty\ weight Maximum\ weight
        Horsepower Seats Wings].each do |attrib|
      assert_select('dt', attrib)
    end
    %w[make model empty_weight_lbs max_weight_lbs
        horsepower seats wings].each do |attrib|
      assert_select('dd', /#{mm.send(attrib)}/)
    end
  end
end
