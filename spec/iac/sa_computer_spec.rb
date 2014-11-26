module Ranking
  describe Computer do
    it 'reports ranks from vector of scalars' do
      v = [1, 1, 1, 1, 1, 1]
      vr = Ranking::Computer.ranks_for(v)
      vr.should == v
      v = [1, 2, 3, 4, 5, 6]
      vr = Ranking::Computer.ranks_for(v)
      vr.should == v.reverse
      v = [6, 5, 4, 3, 2, 1]
      vr = Ranking::Computer.ranks_for(v)
      vr.should == v.reverse
      vr = Ranking::Computer.ranks_for([81, 82, 81, 94, 66, 63])
      vr.should == [3, 2, 3, 1, 5, 6]
      vr = Ranking::Computer.ranks_for([8.1, 8.2, 8.1, 9.4, 6.6, 6.3])
      vr.should == [3, 2, 3, 1, 5, 6]
      vr = Ranking::Computer.ranks_for([8, 8.2, 8, 9.4, 6.6, 6])
      vr.should == [3, 2, 3, 1, 5, 6]
    end
    it 'reports rank matrix from value matrix' do
      m = [
        [1, 1, 1, 1], 
        [2, 2, 2, 2], 
        [3, 3, 3, 3]]
      mr = Ranking::Computer.rank_matrix(m)
      mr.should == [
        [3, 3, 3, 3],
        [2, 2, 2, 2],
        [1, 1, 1, 1]]
      mr = Ranking::Computer.rank_matrix([
        [3, 8, 2], 
        [7, 1, 4], 
        [9, 2, 8], 
        [6, 2, 6]])
      mr.should == [
        [4, 1, 4],
        [2, 4, 3],
        [1, 2, 1],
        [3, 2, 2]]
    end
  end
end
