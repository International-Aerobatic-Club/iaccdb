require 'spec_helper'

describe Airplane do
  it 'captures make, model, and registration' do
    make = 'Bucher Jungman'
    model = '131'
    reg = 'CAXAL'
    airplane = Airplane.find_or_create_by_make_model_reg(make, model, reg)
    airplane.reg.should == reg
    airplane.make.should == make
    airplane.model.should == model
    eAirplane = Airplane.find_or_create_by_make_model_reg(make, model, reg)
    eAirplane.id.should == airplane.id
  end
end
