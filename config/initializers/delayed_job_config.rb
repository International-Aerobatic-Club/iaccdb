Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 10
Delayed::Worker.max_attempts = 1
Delayed::Worker.max_run_time = 20.minutes
Delayed::Job.attr_accessible :priority, :payload_object, :handler, :run_at, :failed_at
