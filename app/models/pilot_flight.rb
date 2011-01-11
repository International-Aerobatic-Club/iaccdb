class PilotFlight < ActiveRecord::Base
  belongs_to :flight
  belongs_to :pilot, :class_name => 'Member'
  has_many :scores, :dependent => :destroy

  def display
    "Flight #{flight.display} for pilot #{pilot.display}"
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
  def gatherScores
    jfs = scores.collect { |s| s.values }
    # jfs[j][f] has score from judge j for figure f
    fjs = []
    jfs.each_with_index do |afs,j|
      afs.each_with_index do |s,f|
        fjs[f] ||= []
        fjs[f][j] = s
      end
    end
    # fjs[f][j] has score for figure f from judge j
    fjs
  end
end
