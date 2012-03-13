module Manny

class Seq
  attr_accessor :pres, :figs, :ctFigs

  def initialize()
    @figs = []
  end
  
  def to_s
    "Manny sequence presentation: #{pres}, figure_k's: #{figs}, figure_count: #{ctFigs}"
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
  attr_accessor :pid, :name, :chief

  def initialize(pid, name)
    @pid = pid
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
  def seq_for(pid)
    ks[pid] || ks[0]
  end

  def penalty(pid)
    penalties[pid] || 0
  end

end

CATEGORY_NAMES = [ nil ] + IAC::Constants::CATEGORY_NAMES
FLIGHT_NAMES = [ nil ] + IAC::Constants::FLIGHT_NAMES

class Category
  attr_accessor :flights, :pilots, :name, :pid

  def initialize(pid, name)
    @pid = pid
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

  # this is needed for primary and sportsman where the sequence
  # for subsequent flights may be the same as the for the first
  # the manny data supplies only the known. it does not repeat.
  def forwardfill_sequences
    seq = flights[1].ks[0] if flights[1]
    flights.each do |f|
      f.ks[0] ||= seq if f
    end if seq
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
    "Manny score pilot #{pilot}, judge #{judge}, sequence #{seq}"
  end
end

class Participant
  attr_accessor :givenName, :familyName, :iacID

  def initialize(givenName, familyName, iacID)
    @givenName = givenName
    @familyName = familyName
    @iacID = iacID # integer
  end
end

class Contest
  attr_accessor :participants, :categories
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
  def seq_for(cat, flt, pilot)
    flight(cat, flt).seq_for(pilot) || flight(cat, 1).seq_for(pilot)
  end

  def pilot(cat, pid)
    category(cat).pilot(pid)
  end

  def manny_date=(value)
    @manny_date = Time.parse(value + ' UTC')
  end

  def record_date=(value)
    begin
      @record_date = Time.parse(value + ' UTC')
    rescue ArgumentError
      @record_date = Time.now
    end
  end
end

end
