require 'test_helper'

class MakeModelServiceTest < ActiveSupport::TestCase
  class OldAirplane < ActiveRecord::Base
    self.table_name = 'airplanes'
    def self.fake_reg
      Faker::Number.between(100, 999).to_s + Faker::Name.initials(2)
    end
  end

  setup do
    16.times do
      airplane = OldAirplane.new(
        make: Faker::Company.name,
        model: Faker::Company.unique.name,
        reg: OldAirplane.fake_reg
      )
      airplane.save!
    end
    Airplane.all.each_with_index do |a, i|
      if i % 3 == 0
        OldAirplane.new(
          make: a.make,
          model: a.model,
          reg: OldAirplane.fake_reg
        )
      end
      if i % 2 == 0
        OldAirplane.new(
          make: a.make,
          model: a.model,
          reg: OldAirplane.fake_reg
        )
      end
    end
  end

  test 'setup produces airplanes without make_model' do
    refute(Airplane.all.any? { |a| a.make_model })
  end

  test 'associate_make_model_with_service' do
    MakeModelService.associate_airplane_make_models
    assert(Airplane.all.all? { |a| a.make_model })
  end

  test 'make_models_match' do
    MakeModelService.associate_airplane_make_models
    Airplane.all.all? do |a|
      assert_equal(a.make, a.make_model.make)
      assert_equal(a.model, a.make_model.model)
    end
  end
end
