# recompute all of the contest metrics
# use rails runner lib/iac/recomputeMetrics.rb <file>

pcs = []
CResult.all.each do |c_result|
  cur = "contest #{c_result.contest.name}, category #{c_result.display_category}"
  begin
    puts "Working with #{cur}"
    c_result.compute_category_totals_and_rankings(true)
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

