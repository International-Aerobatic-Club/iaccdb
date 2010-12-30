# assume loaded with rails environment for iac contest data application

require "iac/mannyModel"

# this class contains methods to map the parsed manny model
# into records of the contest database
# for sanity, variables that reference the manny model have prefix 'm'
# variables that reference the database model have prefix 'd'
module IAC
class MannyToDB
attr_reader :dContest

# accept a parsed manny model of contest results
# appropriately update or create records in the contest database
def process_contest(manny, alwaysUpdate = false)
  r = MannySynch.contest_action(manny.contest)
  dMannySynch = r[0]
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


def process_person(line)
  ma = line.split("\t")
  pid = ma[0].to_i
  gName = ma[2]
  famName = ma[1]
  iac_id = ma[3]
  m = Member.where(:iac_id => iac_id).first
  if m 
    Member.logger.info "Found member #{m.display}"
    if m.given_name.downcase != gName.downcase
      Member.logger.warn "Member given name mismatch overwriting with #{gName}"
      m.given_name = gName;
      m.save
    end
    if m.family_name.downcase != famName.downcase
      Member.logger.warn "Member family name mismatch overwriting with #{famName}"
      m.family_name = famName;
      m.save
    end
  else
    m = Member.create(
      :iac_id => iac_id,
      :given_name => gName,
      :family_name => famName)
    Member.logger.info "New member #{m.display}"
  end
  @parts[pid] = m
end

end #class
end #module
