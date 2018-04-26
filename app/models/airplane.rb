class Airplane < ApplicationRecord
  has_many :pilot_flights, :dependent => :nullify
  belongs_to :make_model
  before_save :check_make_and_model_relation

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

  # split combined make and model into separate make and model
  # returns array [make, model]
  def self.split_make_model(make_model)
    make = model = nil
    if make_model
      amm = make_model.split(' ')
      if (1 < amm.length)
        model = amm.slice(1,make_model.length-1).join(' ')
        make = amm[0]
      else
        model = amm[0]
      end
    end
    [make, model]
  end

  def description
    "#{make} #{model} #{reg}"
  end

  def to_s
    description
  end

  #######
  private
  #######

  def check_make_and_model_relation
    if make or model
      begin
        self.make_model = MakeModel.find_or_create_by(make: make, model: model)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end
end
