require 'test_helper'

module Admin
  class JasperControllerTest < ActionDispatch::IntegrationTest
    test 'can post file' do
      update_xml = File.read('spec/fixtures/jasper/jasperResultsFormat.xml')
      post admin_jasper_url, params: { contest_xml: update_xml }
      assert_response :success
      assert(@response.body.include?("<cdbId>"))
    end

    test 'missing parameter returns client error' do
      post admin_jasper_url
      assert_response :bad_request
      assert(@response.body.include?("<exception>"))
      assert(@response.body.include?("<message>"))
    end

    test 'post empty returns client error' do
      post admin_jasper_url, params: { contest_xml: '' }
      assert_response :bad_request
      assert(@response.body.include?("<exception>"))
      assert(@response.body.include?("<message>"))
    end
  end
end
