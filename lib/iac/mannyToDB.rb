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
  r = MannySynch.contest_action(manny.contest)
  dMannySynch = r[0] # Manny Synch record from the database
  case r[1]
    when 'create'
      @dContest = createContest(manny.contest, dMannySynch)
    when 'update'
      @dContest = updateContest(manny.contest, dMannySynch)
    when 'skip'
      if alwaysUpdate
        @dContest = updateContest(manny.contest, dMannySynch)
      else
        Contest.logger.info("MannyToDB skipping contest #{manny.contest}")
        @dContest = nil
      end
  end
  Contest.logger.debug("MannyToDB has dContest #{@dContest.display}")
  if @dContest
    process_participants(manny.contest)
    process_categories(manny.contest)
  end
end

###
private
###

# the contest does not yet exist. set it up.
# mContest : the manny contest model
# dMannySynch : the synch record for the model
# returns a properly initialized contest record
def createContest(mContest, dMannySynch)
  dContest = Contest.new(
    :name => mContest.name,
    :city => mContest.city,
    :state => mContest.state,
    :start => mContest.record_date,
    :chapter => mContest.chapter,
    :director => mContest.director,
    :region => mContest.region)
  Contest.logger.info "New contest #{dContest.display}"
  dContest.save
  dMannySynch.contest = dContest
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
  if !dContest
    dContest = createContest(mContest, dMannySynch)
    msg = "Expected contest #{dContest.display} was missing, created." 
    Contest.logger.warn msg
  else
    Contest.logger.info "Updating contest #{dContest.display}"
    Flight.delete_all(:contest_id => dContest, :aircat => mContest.aircat)
  end
  dContest
end

# find or create member with bad or mismatched IAC ID
# member family and given names must match exatly, otherwise
# this creates a new member record
def member_name_fallback(mPart)
  dm = Member.where(:family_name => mPart.familyName, 
    :given_name =>mPart.givenName).first
  if dm
    Member.logger.info "Found by name member #{dm.display}"
  else
    dm = Member.create(
      :iac_id => mPart.iacID,
      :given_name => mPart.givenName,
      :family_name => mPart.familyName)
    Member.logger.info "New member #{dm.display}"
  end
  dm
end

# find or create member with good IAC ID
# IAC ID and family name must match exactly, otherwise this falls
# back to exact match of family name and given name
def member_by_iacID(mPart)
  dm = Member.where(:iac_id => mPart.iacID).first
  if dm 
    Member.logger.info "Found member #{dm.display}"
    if dm.family_name.downcase != mPart.familyName.downcase
      # different, fallback to name match
      Member.logger.warn "Member family name mismatch" +
        " manny has #{mPart.familyName}"
      dm = member_name_fallback(mPart)
    end
  else
    dm = member_name_fallback(mPart)
  end
  dm
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
        dm = member_by_iacID(mp)
      else
        Member.logger.warn("#{mp.givenName} #{mp.familyName} missing IAC ID")
        dm = member_name_fallback(mp)
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
    dFlight.chief = @parts[mFlight.chief]
    dFlight.save
    process_flight_judges(dFlight, mFlight)
    process_flight_scores(dFlight, mCat, mFlight)
  end
end

# Initialize hash @judges of judge pdx to Judge db record
def process_flight_judges(dFlight, mFlight)
  @judges = {}
  mFlight.judges.each do |j|
    dJ = @parts[j]
    if !dJ
      msg = "Missing judge #{j} for #{dFlight.display}"
      Judge.logger.error(msg)
    end
    dA = nil
    mpida = mFlight.assists[j]
    if mpida
      dA = @parts[mpida]
    end
    if !dA
      msg = "Missing assistant for #{dFlight.display}, judge #{dJ.display}"
      Judge.logger.warn(msg)
    end
    puts "Judge #{dJ} is #{dJ.display}"
    dJudge = Judge.where(:judge_id => dJ, :assist_id => dA).first ||
      Judge.create(:judge => dJ, :assist => dA)
    if !dJudge
      msg = "Failed create judge #{dJ} for #{dFlight.display}"
      puts msg
      Judge.logger.error(msg)
    else
      puts "#{dJudge.display}"
    end
    @judges[j] = dJudge
  end
end

def process_flight_scores(dFlight, mCat, mFlight)
  mFlight.scores.each do |mScore|
    mParti = mScore.pilot
    mPilot = mCat.pilots[mParti]
    dPilot = @parts[mParti]
    dPilotFlight = get_pilot_flight(dPilot, dFlight, mPilot.chapter)
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
