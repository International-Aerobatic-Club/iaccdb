#require 'iac/constants'

module Manny
module Model

class Seq
  attr_accessor :pres, :figs, :ctFigs

  def initialize()
    @figs = []
  end
  
  def to_s
    "Manny sequence presentation: #{pres}, figure_k's: #{figs.join(',')}, figure_count: #{ctFigs}"
  end
end

class Pilot
  attr_accessor :part, :chapter, :make, :model, :reg

  def initialize(part)
    @part = part # participant index
  end

  def to_s
    "Manny pilot part id: #{part} flying #{make} #{model} #{reg}"
  end
end

class Flight
  attr_accessor :penalties, :ks, :judges, :assists, :chiefAssists, :scores
  attr_accessor :fid, :name, :chief

  def initialize(fid, name)
    @fid = fid
    @name = name
    @penalties = {} # int indexed by pilot pdx
    @ks = {} # Seq indexed by pilot pdx
    @judges = [] # array of pdx
    @assists = {} # hash of assistant pdx indexed by judge pdx
    @chiefAssists = [] # array of pdx
    @scores = [] # array of scores for this flight
  end

  def seq_create(pid)
    ks[pid] ||= Seq.new
  end

  # pid is a one-based index for the pilot from the manny file
  # use seq_for(0) to get known flight k values for all pilots
  # returns nil when there is no specific sequence for the specified pid
  def seq_for(pid)
    seq = ks[pid]
    Parse.logger.debug("seq_for flight #{fid}, pid #{pid} is #{seq}")
    seq
  end

  def penalty(pid)
    penalties[pid] || 0
  end

  def to_s
    "Flight #{name} id #{fid}"
  end
end

CATEGORY_NAMES = [ nil ] + IAC::Constants::CATEGORY_NAMES
FLIGHT_NAMES = [ nil ] + IAC::Constants::FLIGHT_NAMES

class Category
  attr_accessor :flights, :pilots, :name, :cid

  def initialize(cid, name)
    @cid = cid
    @name = name
    @flights = [] # Flight indexed by flightID
    @pilots = [] # Pilot indexed by part
  end
  
  def flight flt
    flights[flt] ||= Flight.new(flt, FLIGHT_NAMES[flt])
  end

  def pilot pid
    pilots[pid] ||= Pilot.new(pid)
  end

  def to_s
    "Category #{name} id #{cid}"
  end
end

class Score
  attr_accessor :pilot, :judge, :seq

  def initialize(seq, pilot, judge)
    @seq = seq
    @pilot = pilot # participant index
    @judge = judge # participant index
  end

  def to_s
    "Manny score pilot #{pilot}, judge #{judge}, values #{seq}"
  end
end

class Participant
  attr_accessor :givenName, :familyName, :iacID

  def initialize(givenName, familyName, iacID)
    @givenName = givenName
    @familyName = familyName
    @iacID = iacID # integer
  end

  def to_s
    "Participant #{givenName} #{familyName} #{iacID}"
  end
end

class Contest
  attr_accessor :participants, :categories, :code
  attr_accessor :name, :region, :dateAdv, :director, :city, :state
  attr_accessor :chapter, :aircat, :mannyID, :manny_date, :record_date

  def initialize()
    @participants = [] # array of participant. pdx indexes this array
    @categories = {} # hash of categories. catID indexes the hash
    @scores = [] # array of scores in no particular index order
  end

  def category cat
    categories[cat] ||= Category.new(cat, CATEGORY_NAMES[cat])
  end

  def flight(cat, flt)
    category(cat).flight(flt)
  end

  # search for the sequence
  # on pri, spn, the known sequence isn't repeated for each flight
  # a spn free isn't repeated for the third flight
  def seq_for(cat, flt, pilot)
    Parse.logger.debug("seq_for category #{cat}, flight #{flt}, pilot #{pilot}")
    case flt
    when 1
      # always the known
      seq = flight(cat, 1).seq_for(0) 
    when 2
      # pilot specific for imdt to advanced
      # sometimes pilot specific for spn, the known when not
      # the known for primary
      seq = flight(cat, 2).seq_for(pilot) || flight(cat, 1).seq_for(0)
    when 3
      # imdt to advanced fly unknown sequence zero
      # sometimes pilot specific for spn, the known when not
      # the known for primary
      seq = flight(cat, 3).seq_for(0) || 
        flight(cat, 2).seq_for(pilot) || flight(cat, 1).seq_for(0)
    else
      Parse.logger.error("seq_for missing sequence not flt 1, 2, or 3")
    end
    Parse.logger.debug("seq_for seq is #{seq}")
    seq
  end

  def pilot(cat, pid)
    category(cat).pilot(pid)
  end

  def manny_date=(value)
    @manny_date = Chronic.parse(value)
  end

  def record_date=(value)
    begin
      @record_date = Chronic.parse(value)
    rescue ArgumentError
      @record_date = Time.now
    end
  end
  
  def to_s
    "Contest #{name} manny id #{mannyID} date #{manny_date}"
  end
end

end
end
