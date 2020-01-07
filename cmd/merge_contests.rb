# use rails runner cmd/merge_contests.rb
# will merge a second contest into the first

def helps
  puts 'Merges the second specified contest into the first'
  puts 'Specify two contest identifiers.'
end

def do_merger(target, other)
  merger = ContestMergeService.new(target)
  merger.merge_contest(other)
  puts "Contest #{other.name} merged into #{target.name}"
end

if (ARGV.length == 2)
  begin
    target = Contest.find(ARGV[0])
    other = Contest.find(ARGV[1])
    puts "Contest #{other.name} to be merged into #{target.name}"
    print 'Type "yes" and press enter to confirm, anything else to cancel: '
    do_merger(target, other) if (STDIN.gets.strip.downcase.eql?("yes"))
  rescue => e
    helps
    puts "Error is #{e.message}"
  end
else
  helps
end
