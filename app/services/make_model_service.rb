class MakeModelService
  attr_reader :target, :source

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

  def self.logger
    @logger ||= LogChanges.new
  end

  def initialize(target, source)
    @target = target
    @source = source
  end

  def merge(logger = nil)
    logger ||= self.class.logger
    logger.log_merge(target, source)
    source.airplanes.update_all(make_model_id: target.id)
    source.destroy!
  end
end
