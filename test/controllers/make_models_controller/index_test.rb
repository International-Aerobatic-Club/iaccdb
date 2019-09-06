require 'test_helper'
require 'shared/make_models_data'

# markup like this:
# <dl class="make-models">
#   <dt class="make">Pitts</dt>
#   <dd class="make">
#     <ul class="models">
#       <li class="model">S1T</li>
#       <li class="model">S1S</li>
#     </ul>
#   </dd>
#   <dt class="make">Extra</dt>
#   <dd class="make">
#     <ul class="models">
#       <li class="model">300L</li>
#       <li class="model">300SC</li>
#     </ul>
#   </dd>
# </dl>
class MakeModelsController::IndexTest < ActionDispatch::IntegrationTest
  include MakeModelsData

  test 'index view' do
    mmods = setup_make_models_data
    get make_models_url
    assert_response :success
    assert_select('dl.make-models', 1)
    assert_select('dl.make-models dt.make', mmods.keys.length)
    assert_select('dl.make-models') do |dl|
      dl = dl.first
      mmods.each_key do |make|
        dt = dl.xpath("./dt[@class='make' and contains(text(), \"#{make}\")]")
        assert_equal(1, dt.length, "dt for make, with text, \"#{make}\"")
        dd = dt.first.xpath('./following-sibling::dd').first
        mmods[make].each do |mr|
          li = dd.xpath("./ul[@class='models']/li[@class='model' and " +
            "contains(text(), \"#{mr.model}\")]").first
          assert_match(/👍/, li.text) if mr.curated
          refute_match(/👍/, li.text) unless mr.curated
        end
      end
    end
  end

  test 'blank make in index' do
    mm = create(:make_model, make: "")
    get make_models_url
    assert_select('dl.make-models dt.make', "{no make specified}")
    assert_select('dl.make-models dd.make ul.models li.model') do |li|
      assert_match(/#{mm.model}/, li.text)
    end
  end

  test 'blank model in index' do
    mm = create(:make_model, model: "")
    get make_models_url
    assert_select('dl.make-models dt.make', mm.make)
    assert_select('dl.make-models dd.make ul.models li.model') do |li|
      assert_match(/\{no model specified\}/, li.text)
    end
  end
end
