class Airplane < ActiveRecord::Base
  attr_accessible :make, :model, :reg

  has_many :pilot_flights, :dependent => :nullify

  # find or create airplane with given make, model, reg number
  def self.find_or_create_by_make_model_reg(make, model, reg)
    make = make ? make.strip : ''
    model = model ? model.strip : ''
    reg = reg ? reg.strip.upcase : ''
    plane = Airplane.where(:make => make,
      :model => model, :reg => reg).first
    if !plane
      plane = Airplane.create(
        :make => make,
        :model => model,
        :reg => reg)
    end
    plane
  end

  def description
    "#{make} #{model} #{reg}"
  end

end
