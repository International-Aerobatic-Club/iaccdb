class MakeModelService
  attr_reader :target, :source

  def initialize(target, source)
    @target = target
    @source = source
  end

  def self.associate_airplane_make_models
    Airplane.all.each do |a|
      if (a.make or a.model)
        a.make_model = MakeModel.find_or_create_by!(
          make: a.make, model: a.model)
        a.save!
      end
    end
  end

  def target_airplanes
    target.airplanes.to_a
  end

  def source_airplanes
    source.airplanes.to_a
  end
end
