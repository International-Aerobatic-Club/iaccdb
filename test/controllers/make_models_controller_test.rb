require "test_helper"

class MakeModelsControllerTest < ActionDispatch::IntegrationTest
  def test_index
    mmods = build_list :make_model, 4
    hmods = mmods.collect(&:make).uniq.inject([]) do |h, make|
      h << {
        make: make,
        models: create_list(:make_model, 4, make: make)
      }
    end
    get make_models_index_url
    assert_response :success
    puts "PAGE: #{@response.body}"
    puts "HMODS: #{hmods.collect(&:inspect).join("\n")}"
    assert_select('ul.make_models')
    hmods.each do |make|
      assert_select(:xpath,
        '//ul[@class=make_models]/li[@class=make]')
      assert_select(:xpath,
        '//ul[@class=make_models]/li[@class=make]/ul[@class=models]')
      make[:models].each do |mm|
        assert_select(:xpath,
        '//ul[@class=make_models]/li[@class=make]/ul[@class=models]')
      end
    end
  end

  def test_show
    get make_models_show_url
    assert_response :success
  end

end
