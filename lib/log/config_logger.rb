require 'logger'

module Log
  module ConfigLogger
    @@logger = nil

    def logger
      @@logger ||= Logger.new(File.join("#{self.class.name}.log"))
    end

    def logger=(logger)
      @@logger = logger
    end
  end
end
