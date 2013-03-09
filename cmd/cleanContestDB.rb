# find contests from Manny that have code other than one
# retrieve those contests to purge them
# use rails runner cmd/cleanContestDB.rb
#require "iac/manny_connect"

include Manny::Connect

#retrieve and process content of Manny contest list
#returns a list of manny contest id
def processContestList
  contests = []
  pull_contest_list(lambda do |rcd| 
    if !(rcd =~ /ContestList\>/)
      ctst = rcd.split("\t")
      if 12 < ctst.length && ctst[11].to_i != 1
        contests << ctst[0].to_i
      end
    end
  end)
  contests
end

contests = processContestList
contests.each do |manny_number| 
  puts "Queuing Contest #{manny_number}"
  Delayed::Job.enqueue Jobs::RetrieveMannyJob.new(manny_number)
end
