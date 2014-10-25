module ACRO
  describe AcroWebOutputReader do
    include AcroWebOutputReader

    before :all do
      @filtered = read_file('spec/acro/multi_R011s08s17s26.htm')
      expect(@filtered).to_not be_nil
      expect(@filtered.length).to be > 40
    end

    it 'filters all <font> start and end tags' do
      expect(/<\/?font[\s>]/ !~ @filtered).to eq true
    end

    it 'filters all <p> start and end tags' do
      expect(/<\/?p[\s>]/ !~ @filtered).to eq true
    end

    it 'filters ^M characters' do
      expect(// !~ @filtered).to eq true
    end

    it 'converts non-breaking space entity to plain space' do
      expect(/&nbsp;/ !~ @filtered).to eq true
      expect(/>\s+Contest/ =~ @filtered).to_not be_nil
      expect(/>>/ !~ @filtered).to eq true
    end

    it 'converts end row followed by start cell into end row, start row, start cell' do
      expect(/<\/tr>\s+<td/ !~ @filtered).to eq true
    end

  end
end
