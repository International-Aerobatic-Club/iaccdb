# find contests in 2014, 2015 that flew the four minute program
# retrieve the latest data post from that contest
# process the four minute free data only
# recompute that flight
# after all done, recompute the roll-ups
# use rails runner cmd/reprocess_four_minute.rb

pcs = []
contests = Contest.joins(:flights => :category).where(
  "categories.category = 'four minute' and 2014 <= year(contests.start)")
contests.find_each do |c|
  begin
    post = c.data_posts.where(
        has_error: false, is_obsolete: false
      ).order('created_at desc').first
    if (post == nil)
      puts "No valid data post for #{c}"
      pcs << c
    else
      puts "Enqueueing #{post} for contest #{c}"
      Delayed::Job.enqueue Jobs::ProcessJasperJob.new(post.id)
    end
  rescue Exception => e
    puts "\nSomething went wrong with contest #{c}"
    puts e.message
    e.backtrace.each { |l| puts l }
    pcs << c
  end
end
unless pcs.empty?
  puts "There were problems with these:"
  pcs.each { |contest| puts contest }
end

