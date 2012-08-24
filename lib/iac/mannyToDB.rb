# assume loaded with rails ActiveRecord
# environment for IAC contest data application

require "iac/mannyModel"

# this class contains methods to map the parsed manny model
# into records of the contest database
# for sanity:
#   'm' prefixes variables that reference the manny model
#   'd' prefixes variables that reference the database model
module IAC
class MannyToDB
attr_reader :dContest

# accept a parsed manny model of contest results
# appropriately update or create records in the contest database
def process_contest(manny, alwaysUpdate = false)
  mContest = manny.contest
  r = MannySynch.contest_action(mContest)
  dMannySynch = r[0] # Manny Synch record from the database
  Contest.logger.info "M2D contest #{mContest.name} #{mContest.record_date}, " + 
    "code #{mContest.code}, action #{r[1]}, always update #{alwaysUpdate}"
  case r[1]
    when 'create'
      @dContest = createContest(mContest, dMannySynch)
    when 'update'
      @dContest = updateContest(mContest, dMannySynch)
    when 'skip'
      if alwaysUpdate
        @dContest = updateContest(mContest, dMannySynch)
      else
        Contest.logger.info("MannyToDB skipping contest #{mContest}")
        @dContest = nil
      end
  end
  if @dContest
    Contest.logger.debug("MannyToDB has dContest #{@dContest.to_s}")
    process_participants(mContest)
    process_categories(mContest)
  end
  @dContest
end

###
private
###

# the contest does not yet exist. set it up.
# mContest : the manny contest model
# dMannySynch : the synch record for the model
# returns a properly initialized contest record
def createContest(mContest, dMannySynch)
  if (mContest.code.to_i == 1)
    dContest = Contest.new(
      :name => mContest.name,
      :city => mContest.city,
      :state => mContest.state,
      :start => mContest.record_date,
      :chapter => mContest.chapter,
      :director => mContest.director,
      :region => mContest.region)
    Contest.logger.info "New contest #{dContest.to_s}"
    dContest.save
    dMannySynch.contest = dContest
  else
    dContest = nil
  end
  dMannySynch.synch_date = Time.now
  dMannySynch.save
  dContest
end

# the contest exists.  delete existing records
# mContest : the manny contest model
# dMannySynch : the synch record for the model
# returns a properly initialized contest record with
# all flights deleted that correspond to those in the manny model
# note power and glider flights for one contest share that contest
# in the contest record.  manny separates them into separate contests
def updateContest(mContest, dMannySynch)
  dContest = dMannySynch.contest
  if (mContest.code.to_i == 1)
    if !dContest
      dContest = createContest(mContest, dMannySynch)
      if (dContest)
        Contest.logger.info "Expected contest #{dContest.to_s} was missing, created." 
      else
        Contest.logger.info "Unable to create contest for #{mContest.name}, " +
          "manny number #{mContest.mannyID}"
      end
    else
      Contest.logger.info "Updating contest #{dContest.to_s}"
      dContest.flights.destroy_all
      dContest.c_results.destroy_all
    end
  elsif dContest
    Contest.logger.info "Removing contest #{dContest.to_s}"
    dContest.destroy
    dContest = nil
  end
  dMannySynch.synch_date = Time.now
  dMannySynch.save
  dContest
end

# initialize an array @parts of member database records to match the
# participant indices used in the manny model
# update and add member entries as required
# note that IAC ID and family name OR given name and family name
#   must exactly match, otherwise this creates a new member record
# IAC ID zero never matches.  A later name match will update the IAC ID.
# mContest : manny contest model
def process_participants(mContest)
  @parts = [] # maps manny participant number to contest db Member
  mContest.participants.each_with_index do |mp,i| 
    if mp
      if mp.iacID && mp.iacID != 0
        dm = Member.find_or_create_by_iac_number(mp.iacID, mp.givenName, mp.familyName)
      else
        Member.logger.warn("#{mp.givenName} #{mp.familyName} missing IAC ID")
        dm = Member.find_or_create_by_name(mp.iacID, mp.givenName, mp.familyName)
      end
      @parts[i] = dm
    end
  end
end

def process_categories(mContest)
  mContest.categories.each_value do |mCat|
    process_category(mContest, mCat)
  end
end

def process_category(mContest, mCat)
  mCat.flights.each_with_index do |mFlight, i|
    if mFlight
      process_flight(mContest, mCat, mFlight, i)
    end
  end
end

def process_flight(mContest, mCat, mFlight, seq)
  # the k values produce flights in the manny model that were not flown, so...
  # have to check for scores before creating a flight
  if !mFlight.scores.empty? && !mFlight.judges.empty?
    dFlight = Flight.create(
      :contest => @dContest,
      :category => mCat.name,
      :name => mFlight.name,
      :sequence => seq,
      :aircat => mContest.aircat)
    dFlight.chief = @parts[mFlight.chief] if mFlight.chief
    dFlight.save
    process_flight_judges(dFlight, mFlight)
    process_flight_scores(dFlight, mContest, mCat, mFlight)
  end
end

# Initialize hash @judges of judge pdx to Judge db record
def process_flight_judges(dFlight, mFlight)
  @judges = {}
  mFlight.judges.each do |j|
    dJ = @parts[j]
    if !dJ
      msg = "Missing judge #{j} for #{dFlight.to_s}"
      Judge.logger.error(msg)
    end
    dA = nil
    mpida = mFlight.assists[j]
    if mpida
      dA = @parts[mpida]
    end
    if !dA
      msg = "Missing assistant for #{dFlight.to_s}, judge #{dJ.to_s}"
      Judge.logger.warn(msg)
    end
    dJudge = Judge.where(:judge_id => dJ, :assist_id => dA).first ||
      Judge.create(:judge => dJ, :assist => dA)
    if !dJudge
      msg = "Failed create judge #{dJ} for #{dFlight.to_s}"
      Judge.logger.error(msg)
    end
    Contest.logger.debug "judge team #{dJudge} for judge #{j} judge_id #{dJ}, assist_id #{dA}"
    Contest.logger.debug "set judge #{j} to #{dJudge}"
    @judges[j] = dJudge
  end
end

def process_flight_scores(dFlight, mContest, mCat, mFlight)
  mFlight.scores.each do |mScore|
    mParti = mScore.pilot
    mPilot = mCat.pilots[mParti]
    mSeq = mContest.seq_for(mCat.cid, mFlight.fid, mParti)
    dPilot = @parts[mParti]
    dPilotFlight = get_pilot_flight(dPilot, dFlight, mPilot.chapter)
    dPilotFlight.penalty_total = mFlight.penalty(mParti) / 10
    if !dPilotFlight.sequence
      kays = []
      (0..mSeq.ctFigs).each { |f| kays << mSeq.figs[f+1] }
      dSequence = Sequence.find_or_create(kays)
      dPilotFlight.sequence = dSequence
    end
    dPilotFlight.save
    mJi = mScore.judge
    dJudge = @judges[mJi] # get the judge team
    Contest.logger.debug "index #{mJi} mScore #{mScore}" if dJudge == nil
    dScore = Score.create(
      :pilot_flight => dPilotFlight,
      :judge => dJudge,
      :values => [])
    ctF = mSeq.ctFigs
    dScore.values = mScore.seq.figs.slice(1..ctF)
    dScore.values << mScore.seq.pres
    dScore.save
  end
end

def get_pilot_flight(dPilot, dFlight, chapter)
  PilotFlight.where(:pilot_id => dPilot, 
      :flight_id => dFlight).first ||
    PilotFlight.create(
      :pilot => dPilot,
      :flight => dFlight,
      :chapter => chapter)
end

end #class
end #module
