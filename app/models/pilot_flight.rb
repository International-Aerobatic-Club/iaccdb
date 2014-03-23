#require 'iac/saComputer'

class PilotFlight < ActiveRecord::Base
  belongs_to :flight
  belongs_to :pilot, :class_name => 'Member'
  has_many :scores, :dependent => :destroy
  belongs_to :sequence
  has_many :pf_results, :dependent => :destroy
  has_many :pfj_results, :dependent => :destroy
  has_one :contest, :through => :flight
  has_one :category, :through => :flight

  def to_s
    a = "Pilot_flight #{id} #{flight} for pilot #{pilot}"
    a += "\npf_results [#{pf_results.join("\n\t")}]" if pf_results
    a += "\npfj_results [#{pfj_results.join("\n\t")}]" if pfj_results
  end

 # arrange an array of scores for this flight
 # the array contains one entry for each figure
 # each entry is an array of scores in order of judge
 # given score (f,j) where f is figure and j is judge
 # the result array has:
 # [[(1,1),(1,2),(1,3),...,(1,nj)],
 #  [(2,1),(2,2),(2,3),...,(2,nj)],
 #  ...
 #  [(nf,1),(nf,2),(nf,3),...(nf,nj)]
 # ]
 # The zero indices are all nil, reference the returned matrix
 # using indices (1 .. size-1) 
 # Count of figures is fjs.size - 1
 # Count of judges is fjs[1].size - 1
 def gatherScores
   jfs = scores.collect { |s| s.values }
   # jfs[j][f] has score from judge j for figure f
   fjs = []
   jfs.each_with_index do |afs,j|
     afs.each_with_index do |s,f|
       fjs[f+1] ||= []
       fjs[f+1][j+1] = s
     end
   end
   # fjs[f][j] has score for figure f from judge j
   fjs
 end

  # compute or retrieve cached results
  # returns PfResult ActiveRecord instance for this pilot for this flight
  def results(has_soft_zero = false)
    sac = IAC::SaComputer.new(self)
    sac.computePilotFlight(has_soft_zero)
  end
end
