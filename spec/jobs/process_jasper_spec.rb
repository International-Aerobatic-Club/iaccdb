module Jobs
  describe ProcessJasperJob do
    before :context do
      @contest = create :contest
      file = File.new('spec/fixtures/jasper/jasperResultsFormat.xml')
      @valid_xml = file.read
      file.close
      @data_post = DataPost.create
      @data_post.contest = @contest
      @data_post.store(@valid_xml)
      @data_post.save!
    end
    it 'processes the data post without error' do
      job = ProcessJasperJob.new(@data_post.id)
      begin
        job.perform
      rescue => e
        fail "Did not expect exception #{e.message}"
      end
      @data_post.reload
      expect(@data_post.has_error).to be false
      expect(@data_post.error_description).to be nil
    end
    it 'processes the data post into a contest entry' do
      job = ProcessJasperJob.new(@data_post.id)
      job.perform
      @contest.reload
      expect(@contest.name).to eq 'Test Contest US Candian Challenge'
      expect(@contest.region).to eq 'NorthEast'
    end
    it 'processes the contest data' do
      job = ProcessJasperJob.new(@data_post.id)
      job.perform
      @contest.reload
      expect(@contest.name).to eq 'Test Contest US Candian Challenge'
      expect(@contest.region).to eq 'NorthEast'
      expect(@contest.flights.count).to eq 14
    end
    it 'runs the compute workflow' do
      expect(JyResult.all.count).to eq 0
      Delayed::Job.enqueue ProcessJasperJob.new(@data_post.id)
      work_result = Delayed::Worker.new.work_off
      expect(work_result[1]).to eq 0
      expect(JyResult.all.count).to be > 0
    end
  end
end
