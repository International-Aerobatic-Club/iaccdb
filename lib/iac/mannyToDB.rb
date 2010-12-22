module IAC
class Manny

# Contest columns:
# 0 manny id
# 1 aircraft category 'P' or 'G'
# 2 name
# 3 city
# 4 state
# 5 dates string
# 6 contest director
# 7 chapter
# 8 region
# 9 update
# 10 jasper version
# 11 process code
# 12 process code
# 13 contest date of record
def process_contest(line)
  ca = line.split("\t")
  manny_id = ca[0]
  c = Contest.where(:manny_id => manny_id).first
  if c
    Contest.logger.info "Found contest #{c.display}"
  else
    c = Contest.create(
      :manny_id => manny_id,
      :name => ca[2],
      :city => ca[3],
      :state => ca[4],
      :start => ca[13],
      :chapter => ca[7],
      :director => ca[6],
      :region => ca[8],
      :aircat => ca[1])
    Contest.logger.info "New contest #{c.display}"
  end
  @contest = c
end

PROCESS_CONTEST = lambda do |m, line|
  case line
  when /<\/Contest>/ 
    SEEK_SECTION
  else
    m.process_contest(line)
    PROCESS_CONTEST
  end
end

# ContestPersonnel columns:
# 0 = PersID
# 1 = Family name
# 2 = Given name
# 3 = IAC Number
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

PROCESS_PERSON = lambda do |m, line|
  case line
  when /<\/ContestPersonnel>/
    SEEK_SECTION
  else
    m.process_person(line)
    PROCESS_PERSON
  end
end

# ContestJudgesLine columns:
# 0 = CategoryID (1=Pri; 2=Sporty; 3=Int; 4=Adv; 5=Unl; 6=4 min)
# 1 = FlightID (1=Knwn; 2=Free; 3=Unkn1; 4=Unkn2)
# 2 = PersID
# 3 = Judge Type (1=Chief; 2=Scoring; 3=Scoring Assistant; 4=Chief Assist)
# 4 = AssistingID (another PersID for the person that was being assisted)
def process_judge
end

PROCESS_JUDGE = lambda do |m, line| 
  case line
  when /<ContestJudgesLine>/
    SEEK_SECTION
  else
    m.process_judge(line)
    PROCESS_JUDGE
  end
end

SEEK_SECTION = lambda do |m, line| 
  case line
  when /<Contest>/
    PROCESS_CONTEST
  when /<ContestPersonnel>/
    PROCESS_PERSON
  when /<ContestJudgesLine>/
    PROCESS_JUDGE
  else
    SEEK_SECTION
  end
end

def initialize
  @state = SEEK_SECTION
  @parts = []
end

def processLine(line)
  @state = @state.call(self, line)
end

end #class
end #module
