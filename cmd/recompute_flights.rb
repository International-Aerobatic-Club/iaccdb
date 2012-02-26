# recompute all of the contest flight results
# use rails runner lib/iac/recomputeMetrics.rb

pcs = []
Contest.all.each do |contest|
  cur = "contest #{contest.year_name}"
  begin
    puts "Working with #{cur}"
    contest.compute_flights
  rescue Exception => e
    puts "\nSomething went wrong with #{cur}:"
    puts e.message
    e.backtrace.first(5).each { |l| puts l }
    pcs << cur
  end
end
unless pcs.empty?
  puts "There were problems with these:"
  pcs.each { |f| puts f }
end

