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
    get make_models_index_url
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

  def test_show
    get make_models_show_url
    assert_response :success
  end
end
