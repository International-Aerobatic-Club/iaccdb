require 'logger'

# defines local methods 'logger' and 'logger=' wherever included
# logger method will return globally configured logger
# globally configured logger initialized to:
#   DelayedJob::Logger if Delayed job environment available
#   otherwise Rails.logger if Rails environment available
#   otherwise File 'default.log'
# use in any class or module with,
#   include Log::ConfigLogger
module Log
  module ConfigLogger
    @@logger = nil

    def logger
      if @@logger == nil
        if class_exists? 'Rails'
          @@logger = Rails.logger
        elsif class_exists? 'Delayed::Worker'
          @@logger = Delayed::Worker.logger
        else
          @@logger = Logger.new('default.log')
        end
      end
      @@logger
    end

    def logger=(logger)
      @@logger = logger
    end

    #######
    private
    #######

    def class_exists?(class_name)
      klass = Module.const_get(class_name)
      klass.is_a?(Class) || klass.is_a?(Module)
    rescue NameError
      false
    end

  end
end
