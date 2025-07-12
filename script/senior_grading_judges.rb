require 'csv'


MIN_FLIGHTS=250
RECENT_WINDOW = 3 # years


# Key = Member#id, Value = Number of flights graded.
judges = Hash.new

# Key = Member#id, Value = boolean
recent = Hash.new

# Get all Flight#id values for all contests within the past three calendar years
recent_flight_ids = Flight.where(contest: Contest.where('YEAR(start) >= ?', Time.now.year - RECENT_WINDOW)).pluck(:id)


# Tally the number of flights that each member line-judged
JfResult.includes(:judge).find_in_batches do |batch|

  batch.each do |jf_result|

    # Convenience var
    jid = jf_result.judge.judge_id

    # Initialize the Hash entry if necessary, then increment
    judges[jid] ||= 0
    judges[jid] += 1

    # Note whether the flight was within the RECENT_WINDOW
    recent[jid] = true if recent_flight_ids.include? jf_result.flight_id

  end

end


# Now tally the Chief Judges similarly
Flight.find_in_batches do |batch|

  batch.each do |flight|

    # Convenience var, but skip this record if no Chief is listed
    jid = flight.chief_id || next
    judges[jid] ||= 0
    judges[flight.chief_id] += flight.pilot_flights.count
    recent[jid] = true if recent_flight_ids.include? flight.id

  end

end


# Filter and output the results
CSV($stdout) do |csv|

  judges
    # Filter out judges who haven't judged within RECENT_WINDOW or have less than MIN_FLIGHTS flights judged/chiefed
    .find_all{ |k,v| recent[k] && v >= MIN_FLIGHTS }
    # Produce an array of CSV columns
    .map{ |jid,v| ["#{Member.find(jid).given_name} #{Member.find(jid).family_name}", jid, v] }
    .sort
    .each{ |cols| csv << cols }

end
