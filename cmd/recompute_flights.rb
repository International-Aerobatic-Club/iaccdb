# recompute all of the contest flight results
# use rails runner lib/iac/recomputeMetrics.rb

year = ARGV.empty? ? 0 : ARGV[0].to_i
cur_year = Date.today.year
year = cur_year if cur_year < year || year < 1990
pcs = []
Contest.where("year(start) = #{year}").each do |contest|
  cur = "contest #{contest.year_name}"
  begin
    puts "Working with #{cur}"
    contest.results
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

