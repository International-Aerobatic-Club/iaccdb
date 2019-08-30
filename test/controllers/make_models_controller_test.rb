require 'test_helper'
require 'shared/make_models_data'

# markup like this:
# <ul class="make_models">
#   <li class="make">Pitts
#     <ul class="models">
#       <li class="model">S1T</li>
#       <li class="model">S1S</li>
#     </ul>
#   </li>
#   <li class="make">Extra
#     <ul class="models">
#       <li class="model">300L</li>
#       <li class="model">300SC</li>
#     </ul>
#   </li>
# </ul>
class MakeModelsControllerTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  def test_index
    mmods = setup_make_models_data
    get make_models_url
    assert_response :success
    assert_select('ul.make_models', 1)
    assert_select('ul.make_models li.make', mmods.keys.length)
    mmods.each_key do |make|
      assert_select('ul.make_models li.make', /#{make}/)
      mmods[make].each do |mr|
        assert_select('ul.make_models li.make ul.models li.model',
          /#{mr.model}/)
      end
    end
  end

  # <h1>S1T</h1>
  # <dl class="make-model">
  #   <dt>Make</dt><dd>Pitts</dd>
  #   <dt>Model</dt><dd>S1T</dd>
  #   <dt>Empty weight</dt><dd>780 lbs</dd>
  #   ...
  # <dl>
  def test_show
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
