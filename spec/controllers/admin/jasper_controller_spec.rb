describe Admin::JasperController, type: :controller do
  before(:all) do
    file = File.new('spec/fixtures/jasper/jasperResultsFormat.xml')
    @valid_xml = file.read
    file.close
    file = File.new('spec/fixtures/jasper/jasperResultsErrorFormat.xml')
    @invalid_xml = file.read
    file.close
    file = File.new('spec/fixtures/jasper/jasperResultsUpdateFormat.xml')
    @update_xml = file.read
    file.close
  end

  it 'writes post data record on post data inline' do
    post :results, params: { contest_xml: @valid_xml }
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.data).not_to be_nil
    expect(prcd.has_error).to eq false
    expect(response).to be_success
  end

  it 'writes post data record on post data upload' do
    post :results, params: { contest_xml: @valid_xml }
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.data).not_to be_nil
    expect(prcd.has_error).to eq false
    expect(response).to be_success
  end

  it 'responds with a 400 error on missing post data' do
    post :results
    expect(response).not_to be_success
    expect(response.status).to eq(400)
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.has_error).to eq true
    expect(prcd.error_description).not_to be_nil
    expect(prcd.data).not_to be_nil
  end

  it 'writes post data failure record on failure' do
    post :results, params: { contest_xml: @invalid_xml }
    expect(response).not_to be_success
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.has_error).to eq true
    expect(prcd.error_description).not_to be_nil
    expect(prcd.data).not_to be_nil
  end

  context ('render views') do
    render_views
    it 'returns new contest id when no cdbId' do
      post :results, params: { contest_xml: @valid_xml }
      expect(response).to be_success
      expect(response.body).to match(/\<cdbId\>[1-9]+\<\/cdbId\>/)
    end

    it 'returns existing contest id when cdbId provided' do
      post :results, params: { contest_xml: @update_xml }
      expect(response).to be_success
      expect(response.body).to match(/\<cdbId\>337\<\/cdbId\>/)
    end
  end

  it 'writes post data with contest id when no cdbId' do
    post :results, params: { contest_xml: @valid_xml }
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.has_error).to eq false
    expect(prcd.error_description).to be_nil
    expect(prcd.data).not_to be_nil
    expect(prcd.contest_id).to be >= 1
  end

  it 'writes post data with contest id when cdbId provided' do
    post :results, params: { contest_xml: @update_xml }
    prcd = DataPost.all.first
    expect(prcd).not_to be_nil
    expect(prcd.has_error).to eq false
    expect(prcd.error_description).to be_nil
    expect(prcd.data).not_to be_nil
    expect(prcd.contest_id).to eq(337)
  end

end
