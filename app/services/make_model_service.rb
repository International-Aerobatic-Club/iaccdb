class MakeModelService
  attr_reader :target_id, :source_id

  class LogChanges
    def initialize
      logfile_name = Rails.root.join('log', 'make_model_merges.log')
      @logger = Logger.new(logfile_name, shift_age = 'weekly', level: :info)
    end

    def log_merge(target, source)
      source_attrs = source.attributes.reject { |key| key == "id" }
      @logger.info(<<~MSG
        #{Rails.env.upcase} : Airplanes moved to
          MakeModel #{target.id}: #{target.make}, #{target.model}
          and source deleted. To restore, try:
        mm = MakeModel.new(#{source_attrs})
        mm.save!
        ars = Airplane.find([#{source.airplanes.collect(&:id).join(", ")}])
        ars.each { |ar| ar.update(make_model_id: mm.id) }
      MSG
      )
    end
  end

  class << self
    def logger
      @logger ||= LogChanges.new
    end

    def associate_airplane_make_models
      Airplane.all.each do |a|
        if (a.make or a.model)
          a.make_model = MakeModel.find_or_create_by!(
            make: a.make, model: a.model)
          a.save!
        end
      end
    end
  end

  def initialize(target, source)
    @target_id = target.id
    @source_id = source.id
  end

  def merge(logger = nil)
    logger ||= self.class.logger
    source = MakeModel.find(source_id)
    target = MakeModel.find(target_id)
    logger.log_merge(target, source)
    source.airplanes.update_all(make_model_id: target_id)
    source.destroy!
  end
end
