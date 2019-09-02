class MakeModelService
  attr_reader :target_id, :source_id

  def initialize(target, source)
    @target_id = target.id
    @source_id = source.id
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

  def merge
    source = MakeModel.find(source_id)
    source.airplanes.update_all(make_model_id: target_id)
    source.destroy!
  end
end
