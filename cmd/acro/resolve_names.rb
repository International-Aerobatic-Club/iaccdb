# do NOT use rails runner
# rails runner is non-interactive
# use ruby cmd/resolve_names.rb <file>
require_relative File.expand_path('../../config/environment', __FILE__)

args = ARGV
ctlFile = args[0]
if (ctlFile)
  contest_names = ACRO::ContestNames.new(ctlFile)
  contest_names.match_names_to_records
  puts "Name selection complete"
else
  puts 'Supply the name of the contest information file'
end
