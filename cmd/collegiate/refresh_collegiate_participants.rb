# read data posts and refresh the collegiate competitors and teams
# for a given year
# use rails runner cmd/collegiate/refresh_collegiate_participants.rb

def process_data_posts(year)
  cparts = CollegiateParticipants.new(year)
  posts = DataPost.where(['year(created_at) = ? and is_obsolete = false', 
    year]).order('created_at')
  pcs = []
  posts.each do |post|
    begin
      if (post.has_error)
        puts "Skipping post #{post} has error, #{post.error_description}"
      elsif (post.is_obsolete)
        puts "Skipping post #{post} is obsolete"
      else
        puts "Processing #{post}"
        cparts.process_post(post)
      end
    rescue Exception => e
      puts "\nSomething went wrong with #{post}:"
      puts e.message
      e.backtrace.each { |l| puts l }
      pcs << post
    end
  end
  unless pcs.empty?
    puts "There were problems with these:"
    pcs.each { |post| puts post }
  end
  cparts.print_results
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
unless year && year != 0
  puts "Specify the year will refresh collegiate participants"
  puts "  from JaSPer posts for that year.  Never deletes."
  exit 1
end
process_data_posts(year)

