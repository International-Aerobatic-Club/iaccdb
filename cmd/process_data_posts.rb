# read data posts and queue jobs to process them
# use rails runner cmd/process_data_posts.rb
require 'xml'

posts = DataPost.where(:is_integrated => false, 
    :is_obsolete => false).order('created_at DESC')
pcs = []
posts.each do |post|
  begin
    if (post.has_error)
      puts "Skipping post #{post} has error, #{post.error_description}"
    elsif (post.is_obsolete)
      puts "Skipping post #{post} is obsolete"
    else
      puts "Enqueueing #{post}"
      Delayed::Job.enqueue Jobs::ProcessJasperJob.new(post.id)
      posts.each do |p| 
        if p.id != post.id && p.contest_id == post.contest_id
          p.is_obsolete = true 
          p.save
        end
      end
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
