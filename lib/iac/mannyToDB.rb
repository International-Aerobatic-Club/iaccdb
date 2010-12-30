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
    #exception contest should exist
  else
    Contest.logger.info "Found contest #{dContest.display}"
  end
  dContest
end

def process_participants(mContest)
  @parts = [] # maps manny participant number to contest db Member
  mContest.participants.each_with_index do |mp,i| 
    if mp
      dm = Member.where(:iac_id => mp.iacID).first
      if dm 
        Member.logger.info "Found member #{dm.display}"
        if dm.given_name.downcase != mp.givenName.downcase
          Member.logger.warn "Member given name mismatch overwriting with #{mp.givenName}"
          dm.given_name = mp.givenName;
          dm.save
        end
        if dm.family_name.downcase != mp.familyName.downcase
          Member.logger.warn "Member family name mismatch overwriting with #{mp.familyName}"
          dm.family_name = mp.familyName;
          dm.save
        end
      else
        dm = Member.create(
          :iac_id => mp.iacID,
          :given_name => mp.givenName,
          :family_name => mp.familyName)
        Member.logger.info "New member #{dm.display}"
      end
      @parts[i] = dm
    end
  end
end

end #class
end #module
