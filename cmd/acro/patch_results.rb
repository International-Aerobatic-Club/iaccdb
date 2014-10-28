# use rails runner cmd/acro/patch_results.rb <file>

args = ARGV
ctlFile = args[0]
if (ctlFile)
  results_patch = ACRO::ResultsPatch.new(ctlFile)
  pcs = results_patch.patch_flight_results
  if pcs.empty?
    puts "Success patching flight results records."
  else
    puts "There were problems with these category result files:"
    pcs.each { |f| puts f }
  end
else
  puts 'Supply the name of the contest information file'
end
