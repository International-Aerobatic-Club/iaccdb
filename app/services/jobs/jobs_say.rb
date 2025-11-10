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

  def record_failure(step, attributes_hash, exception)
    attributes_hash ||= {}
    attributes_hash[:step] = step
    attributes_hash[:description] =
        ':: ' + exception.message + " ::\n" + exception.backtrace.join("\n")
    failure = Failure.create(attributes_hash)
    notify_admin_of_failure(failure)
  end

  def record_contest_failure(step, contest, exception)
    record_failure(step, { contest_id: contest.id, }, exception)
  end

  def record_post_failure(step, data_post_id, contest_id, exception)
    record_failure(step, {
        data_post_id: data_post_id,
        contest_id: contest_id
      }, exception)
  end
end
end
