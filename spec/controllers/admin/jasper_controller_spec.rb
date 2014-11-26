describe Admin::JasperController do
  before(:all) do
    file = File.new('spec/jasper/jasperResultsFormat.xml')
    @valid_xml = file.read
    file.close
    file = File.new('spec/jasper/jasperResultsErrorFormat.xml')
    @invalid_xml = file.read
    file.close
    file = File.new('spec/jasper/jasperResultsUpdateFormat.xml')
    @update_xml = file.read
    file.close
  end

  it 'writes post data record on post data inline' do
    post :results, :contest_xml => @valid_xml
    prcd = DataPost.all.first 
    prcd.should_not be_nil
    prcd.data.should_not be_nil
    prcd.has_error.should be_false
    response.should be_success
  end

  it 'writes post data record on post data upload' do
    @file = fixture_file_upload('spec/jasper/jasperResultsFormat.xml', 'text/xml')
    post :results, :contest_xml => @file
    prcd = DataPost.all.first 
    prcd.should_not be_nil
    prcd.data.should_not be_nil
    prcd.has_error.should be_false
    response.should be_success
  end
  
  it 'responds with a 400 error on missing post data' do
    post :results
    response.should_not be_success
    response.status.should eq(400)
    prcd = DataPost.all.first 
    prcd.should_not be_nil
    prcd.has_error.should be_true
    prcd.error_description.should_not be_nil
    prcd.data.should be_nil
  end

  it 'writes post data failure record on failure' do
    post :results, :contest_xml => @invalid_xml
    response.should_not be_success
    prcd = DataPost.all.first 
    prcd.should_not be_nil
    prcd.has_error.should be_true
    prcd.error_description.should_not be_nil
    prcd.data.should_not be_nil
  end

  context ('render views') do
    render_views
    it 'returns new contest id when no cdbId' do
      post :results, :contest_xml => @valid_xml
      response.should be_success
      response.body.should match(/\<cdbId\>1\<\/cdbId\>/)
    end

    it 'returns existing contest id when cdbId provided' do
      post :results, :contest_xml => @update_xml
      response.should be_success
      response.body.should match(/\<cdbId\>337\<\/cdbId\>/)
    end
  end

  it 'writes post data with contest id when no cdbId' do
      post :results, :contest_xml => @valid_xml
      prcd = DataPost.all.first 
      prcd.should_not be_nil
      prcd.has_error.should_not be_true
      prcd.error_description.should be_nil
      prcd.data.should_not be_nil
      prcd.contest_id.should eq(1)
  end

  it 'writes post data with contest id when cdbId provided' do
      post :results, :contest_xml => @update_xml
      prcd = DataPost.all.first 
      prcd.should_not be_nil
      prcd.has_error.should_not be_true
      prcd.error_description.should be_nil
      prcd.data.should_not be_nil
      prcd.contest_id.should eq(337)
  end

end
