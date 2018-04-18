module Model
  describe DataPost, :type => :model do
    context 'factory data' do
      before(:all) do
        @data_post = create(:data_post)
      end

      it 'ensures a directory for posts' do
        file_name = @data_post.filename
        expect(Dir.exists?(File.dirname(file_name))).to be true
      end

      it 'writes a string into the file' do
        @data_post.store("<?xml version='1.0'><data>some data</data>")
        expect(File.exists?(@data_post.filename)).to be true
      end

      it 'reads string out of the file' do
        post_in = "<?xml version='1.0'><data>more data</data>"
        @data_post.store(post_in)
        data = @data_post.data
        expect(data).to eq post_in
      end

    end #context factory data
  end #DataPost
end #module
