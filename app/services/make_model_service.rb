class MakeModelService
  def self.associate_airplane_make_models
    Airplane.all.each do |a|
      if (a.make or a.model)
        a.make_model = MakeModel.find_or_create_by!(
          make: a.make, model: a.model)
        a.save!
      end
    end
  end
end
