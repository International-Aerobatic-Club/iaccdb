describe Airplane, :type => :model do
  it 'captures make, model, and registration' do
    make = 'Bucher Jungman'
    model = '131'
    reg = 'CAXAL'
    airplane = Airplane.find_or_create_by_make_model_reg(make, model, reg)
    expect(airplane.reg).to eq reg
    expect(airplane.make).to eq make
    expect(airplane.model).to eq model
    eAirplane = Airplane.find_or_create_by_make_model_reg(make, model, reg)
    expect(eAirplane.id).to eq airplane.id
  end

  it 'splits make model' do
    mm = Airplane.split_make_model('Pitts S-1S')
    expect(mm[0]).to eq 'Pitts'
    expect(mm[1]).to eq 'S-1S'
    mm = Airplane.split_make_model('Decathlon')
    expect(mm[0]).to be_nil
    expect(mm[1]).to eq 'Decathlon'
    mm = Airplane.split_make_model('Extra 330 LX')
    expect(mm[0]).to eq 'Extra'
    expect(mm[1]).to eq '330 LX'
  end

end
