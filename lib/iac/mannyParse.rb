require 'iac/mannyModel'

module Manny
class MannyParse
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
# 12 process code
# 13 contest date of record
def process_contest(line)
  ca = line.split("\t")
  @contest.mannyID = ca[0].to_i
  @contest.aircat = ca[1].strip
  @contest.name = ca[2].strip
  @contest.city = ca[3].strip
  @contest.state = ca[4].strip
  @contest.dateAdv = ca[5].strip
  @contest.director = ca[6].strip
  @contest.chapter = ca[7].strip
  @contest.region = ca[8].strip
  @contest.manny_date = ca[9].strip
  @contest.record_date = ca[13].strip
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
  gName = ma[2].strip
  famName = ma[1].strip
  iac_id = ma[3].to_i
  @contest.participants[pid] = Participant.new(gName, famName, iac_id)
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
  pa = line.split("\t")
  cid = pa[0].to_i # category
  pid = pa[1].to_i # person
  pilot = @contest.pilot(cid, pid)
  pilot.chapter = pa[2].strip
  pilot.make = pa[7].strip
  pilot.model = pa[8].strip
  pilot.reg = pa[9].strip
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
  ks = @contest.seq_for(cid, fid, pid)
  seq.ctFigs = ks.ctFigs
  flight = @contest.flight(cid, fid)
  score = Score.new(ks, pid, jid)
  score.seq = seq
  flight.scores << score
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
    PROCESS_CONTEST
  when /<ContestPersonnel>/
    PROCESS_PERSON
  when /<ContestJudgesLine>/
    PROCESS_JUDGE
  when /<ContestKs>/
    PROCESS_K
  when /<ContestPilots>/
    PROCESS_PILOT
  when /<ContestScores>/
    PROCESS_SCORES
  when /<ContestPenalties>/
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

end #class
end #module
