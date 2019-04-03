require 'test_helper'
require_relative 'contest_data'

module Jasper
  class CategoriesTest < ActiveSupport::TestCase
    include ContestData

    setup do
      @catCt = Category.count
      jasper = jasper_parse_from_test_data_file('jasperResultsFormat.xml')
      j2d = Jasper::JasperToDB.new
      j2d.process_contest(jasper)
    end

    test 'does not invent a new category' do
      assert_equal(@catCt, Category.count)
    end
  end
end
