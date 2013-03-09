module Jobs
module JobsSay
  def say(text, level = Logger::INFO)
    logger = Delayed::Worker.logger
    if logger
      logger.add level, text
    else
      puts text
    end
  end
  
  def record_manny_failure(step, manny_id, exception)
    Failure.create(
      :step => step,
      :manny_id => manny_id,
      :description => 
        ':: ' + exception.message + " ::\n" + exception.backtrace.join("\n"))
  end

  def record_contest_failure(step, contest, exception)
    Failure.create(
      :step => step,
      :contest_id => contest.id,
      :manny_id => contest.manny_synch ? contest.manny_synch.manny_number : nil,
      :description => 
        ':: ' + exception.message + " ::\n" + exception.backtrace.join("\n"))
  end
end
end
