describe PagesController, type: :controller do
  it 'retrieves valid page' do
    get :page_view, params: { title: 'notes' }
    expect(response.status).to eq 200
  end
  it 'rejects attempted hack' do
    get :page_view, params: { title: '../app/views/admin/data_posts/index' }
    expect(response.status).to eq 404
  end
  it 'rejects invalid page' do
    get :page_view, params: { title: 'not_a_page' }
    expect(response.status).to eq 404
  end
end
