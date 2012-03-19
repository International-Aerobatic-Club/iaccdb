module JobsSay
  def say(text, level = Logger::INFO)
    logger = Delayed::Worker.logger
    if logger
      logger.add level, text
    else
      puts text
    end
  end
end
