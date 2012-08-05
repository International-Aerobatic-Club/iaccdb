require 'iac/mannyModel'
require 'log/config_logger'

module Manny
class MannyParse
include Log::ConfigLogger
cattr_accessor :logger
attr_reader :contest

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
# 12 comments
# 13 contest date of record
def process_contest(line)
  ca = line.split("\t")
  @contest.mannyID = ca[0].to_i
  @contest.aircat = columnValue(ca,1)
  @contest.name = columnValue(ca,2)
  @contest.city = columnValue(ca,3)
  @contest.state = columnValue(ca,4)
  @contest.dateAdv = columnValue(ca,5)
  @contest.director = columnValue(ca,6)
  @contest.chapter = columnValue(ca,7)
  @contest.region = columnValue(ca,8)
  @contest.manny_date = columnValue(ca,9)
  @contest.code = columnValue(ca,11)
  @contest.record_date = columnValue(ca,13)
  logger.debug "parsed manny line '#{line}' to contest model #{@contest}"
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
  gName = columnValue(ma,2)
  famName = columnValue(ma,1)
  iac_id = ma[3].to_i
  @contest.participants[pid] = Participant.new(gName, famName, iac_id)
  logger.debug "parsed manny line '#{line}' to participant #{pid} model #{@contest.participants[pid]}"
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
# 4 = AssistingID (another PersID for the judge assisted)
def process_judge(line)
  ja = line.split("\t")
  cid = ja[0].to_i # category
  fid = ja[1].to_i # flight
  pid = ja[2].to_i # person
  flight = @contest.flight(cid,fid)
  case ja[3].to_i
    when 1
      flight.chief = pid
      flight.judges << pid
    when 2
      flight.judges << pid
    when 3
      jid = ja[4].to_i
      flight.assists[jid] = pid
      if (jid == flight.chief)
        flight.chiefAssists << pid
      end
    when 4
      flight.chiefAssists << pid
  end
  logger.debug "parsed manny line '#{line}' to judge #{pid} for flight model #{flight}"
end

PROCESS_JUDGE = lambda do |m, line| 
  case line
  when /<\/ContestJudgesLine>/
    SEEK_SECTION
  else
    m.process_judge(line)
    PROCESS_JUDGE
  end
end

# ContestKs columns
# 0 = CategoryID
# 1 = FlightID
# 2 = Pilot as PersID, 0 = all
# 3 = Presentation K
# 4 .. 24 = figure K
def process_k(line)
  ka = line.split("\t")
  cid = ka[0].to_i # category
  fid = ka[1].to_i # flight
  pid = ka[2].to_i # person
  flight = @contest.flight(cid, fid)
  seq = flight.seq_create(pid)
  fi = 0
  until seq.figs[fi] == 0 || 20 < fi
    fi += 1
    seq.figs[fi] = ka[fi+3].to_i
  end
  seq.ctFigs = fi - 1
  seq.figs[fi] = seq.pres = ka[3].to_i
  logger.debug "parsed manny line '#{line}' to sequence #{seq} for flight model #{flight}"
end

PROCESS_K = lambda do |m, line| 
  case line
  when /<\/ContestKs>/
    SEEK_SECTION
  else
    m.process_k(line)
    PROCESS_K
  end
end

# ContestPilots columns
# 0 = CategoryID
# 1 = PersID
# 2 = Chapter
# 3 .. 6 = names of flights flown
# 7 = aircraft make 
# 8 = aircraft model
# 9 = aircraft registration
def process_pilot(line)
  begin
    pa = line.split("\t")
    cid = pa[0].to_i # category
    pid = pa[1].to_i # person
    pilot = @contest.pilot(cid, pid)
    pilot.chapter = columnValue(pa,2)
    pilot.make = columnValue(pa,7)
    pilot.model = columnValue(pa,8)
    pilot.reg = columnValue(pa,9)
  rescue
    logger.error "Manny parse pilot: trouble with line '#{line}' is #{$!}"
    throw
  end
  logger.debug "parsed manny line '#{line}' to pilot model #{pilot}"
end

PROCESS_PILOT = lambda do |m, line| 
  case line
  when /<\/ContestPilots>/
    SEEK_SECTION
  else
    m.process_pilot(line)
    PROCESS_PILOT
  end
end

# ContestScores columns
# 0 = CategoryID
# 1 = FlightID
# 2 = Pilot as PersID
# 3 = Judge as PersID
# 4 = Presentation Score * 10
# 5 .. 25 = figure Score * 10
def process_scores(line)
  asc = line.split("\t")
  cid = asc[0].to_i # category
  fid = asc[1].to_i # flight
  pid = asc[2].to_i # pilot person
  jid = asc[3].to_i # judge person
  seq = Seq.new
  seq.pres = asc[4].to_i
  for fi in 1 .. 20
    seq.figs[fi] = asc[fi+4].to_i
  end
  flight = @contest.flight(cid, fid)
  score = Score.new(seq, pid, jid)
  flight.scores << score
  logger.debug "parsed manny line '#{line}' to scores model #{score} for flight #{flight}, pilot #{pid}, judge #{jid}"
end

PROCESS_SCORES = lambda do |m, line| 
  case line
  when /<\/ContestScores>/
    SEEK_SECTION
  else
    m.process_scores(line)
    PROCESS_SCORES
  end
end

# ContestPenalties columns:
# 0 = CategoryID
# 1 = FlightID
# 2 = PilotID
# 3 = Penalty
def process_penalty(line)
  ma = line.split("\t")
  cid = ma[0].to_i
  fid = ma[1].to_i
  pid = ma[2].to_i
  flight = @contest.flight(cid, fid)
  flight.penalties[pid] = ma[3].to_i
  logger.debug "parsed manny line '#{line}' to flight model #{flight} penalty for pilot #{pid}"
end

PROCESS_PENALTY = lambda do |m, line|
  case line
  when /<\/ContestPenalties>/
    SEEK_SECTION
  else
    m.process_penalty(line)
    PROCESS_PENALTY
  end
end

SEEK_SECTION = lambda do |m, line| 
  case line
  when /<Contest>/
    logger.debug 'Manny parse contest'
    PROCESS_CONTEST
  when /<ContestPersonnel>/
    logger.debug 'Manny parse contest personnel'
    PROCESS_PERSON
  when /<ContestJudgesLine>/
    logger.debug 'Manny parse judges'
    PROCESS_JUDGE
  when /<ContestKs>/
    logger.debug 'Manny parse sequences'
    PROCESS_K
  when /<ContestPilots>/
    logger.debug 'Manny parse pilots'
    PROCESS_PILOT
  when /<ContestScores>/
    logger.debug 'Manny parse scores'
    PROCESS_SCORES
  when /<ContestPenalties>/
    logger.debug 'Manny parse penalties'
    PROCESS_PENALTY
  else
    SEEK_SECTION
  end
end

def initialize
  @state = SEEK_SECTION
  @contest = Manny::Contest.new
end

def processLine(line)
  @state = @state.call(self, line)
end

private

# safely return non-null, stripped string array item at offset
# strip if not nil
# return empty string if nil
def columnValue(line, offset)
  e = line[offset]
  if e
    e.strip
  else
    ''
  end
end

end #class
end #module
