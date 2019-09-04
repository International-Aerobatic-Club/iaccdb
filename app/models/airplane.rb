class Airplane < ApplicationRecord
  has_many :pilot_flights, :dependent => :nullify
  belongs_to :make_model

  # find or create airplane with given make, model, reg number
  def self.find_or_create_by_make_model_reg(make, model, reg)
    mm = MakeModel.find_or_create_make_model(make, model)
    plane = nil
    begin
      Airplane.transaction(requires_new: true) do
        plane = Airplane.find_or_create_by(make_model: mm, reg: reg)
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    plane
  end

  def description
    "#{make_model.make} #{make_model.model} #{reg}"
  end

  def to_s
    description
  end
end
