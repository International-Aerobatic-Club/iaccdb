require 'spec_helper'

module Model
  describe Sequence do
    before(:all) do
      reset_db
      @k_values = [19, 14, 21, 33, 21, 23, 22, 20, 8]
      @attrs = Sequence.create_attrs(@k_values)
    end
    it 'encodes sequence attributes' do
      @attrs[:figure_count].should == 9
      @attrs[:total_k].should == 181
      @attrs[:mod_3_total].should == 10
    end
    it 'adds a new sequence' do
      Sequence.find_or_create(@k_values)
      Sequence.all.size.should == 1
    end
    it 'finds an existing sequence' do
      Sequence.find_or_create(@k_values)
      Sequence.find_or_create(@k_values)
      Sequence.all.size.should == 1
    end
    it 'finds the k factors for a sequence' do
      seq = Sequence.find_or_create(@k_values)
      seq.figure_count.should == 9
      seq.total_k.should == 181
      seq.mod_3_total.should == 10
      kv = seq.k_values
      (0 ... @k_values.size).each { |i| kv[i].should == @k_values[i] }
    end
  end
end
