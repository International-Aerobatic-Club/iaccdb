describe Category, :type => :model do

  context 'find_for_cat_aircat' do
    it 'identifies power versus glider' do
      p = Category.find_for_cat_aircat('Intermediate', 'P')
      g = Category.find_for_cat_aircat('Intermediate', 'G')
      expect(g.id).to_not eq p.id
      expect(p.aircat).to eq 'P'
      expect(g.aircat).to eq 'G'
    end

    it 'identifies primary power' do
      p = Category.find_for_cat_aircat('Primary', 'P')
      expect(p.category).to eq 'primary'
      expect(p.aircat).to eq 'P'
    end

    it 'identifies four minute' do
      p = Category.find_for_cat_aircat('Four minute', 'F')
      expect(p.category).to eq 'four minute'
      expect(p.aircat).to eq 'F'
    end

    it 'does not confuse four minute with power' do
      p = Category.find_for_cat_aircat('Four minute', 'P')
      expect(p.category).to eq 'four minute'
      expect(p.aircat).to eq 'F'
    end

    it 'does not duplicate four minute' do
      p = Category.find_for_cat_aircat('Four minute', 'F')
      q = Category.find_for_cat_aircat('Four minute', 'P')
      expect(q.id).to eq p.id
    end

    context 'four minute with power aircat exists in database' do
      before :context do
        Category.create!(
          sequence: Category.count + 1,
          category: 'four minute',
          aircat: 'P',
          name: 'Four Minute Free'
        )
      end

      it 'does not confuse four minute with power' do
        p = Category.find_for_cat_aircat('Four minute', 'P')
        expect(p.category).to eq 'four minute'
        expect(p.aircat).to eq 'F'
      end

      it 'does not duplicate four minute' do
        p = Category.find_for_cat_aircat('Four minute', 'F')
        q = Category.find_for_cat_aircat('Four minute', 'P')
        expect(q.id).to eq p.id
      end
    end
  end

end
