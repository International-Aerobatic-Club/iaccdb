module Model
  describe Sequence, type: :model do
    before(:all) do
      @k_values = [19, 14, 21, 33, 21, 23, 22, 20, 8]
      @attrs = Sequence.create_attrs(@k_values)
    end
    it 'encodes sequence attributes' do
      expect(@attrs[:figure_count]).to eq(9)
      expect(@attrs[:total_k]).to eq(181)
      expect(@attrs[:mod_3_total]).to eq(10)
    end
    it 'adds a new sequence' do
      Sequence.find_or_create(@k_values)
      expect(Sequence.all.size).to eq(1)
    end
    it 'finds an existing sequence' do
      Sequence.find_or_create(@k_values)
      Sequence.find_or_create(@k_values)
      expect(Sequence.all.size).to eq(1)
    end
    it 'finds the k factors for a sequence' do
      seq = Sequence.find_or_create(@k_values)
      expect(seq.figure_count).to eq(9)
      expect(seq.total_k).to eq(181)
      expect(seq.mod_3_total).to eq(10)
      kv = seq.k_values
      (0 ... @k_values.size).each { |i| expect(kv[i]).to eq(@k_values[i]) }
    end
  end
end
