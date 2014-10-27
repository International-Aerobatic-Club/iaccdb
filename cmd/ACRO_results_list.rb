# use rails runner cmd/ACRO_results_list.rb <file>

args = ARGV
control_file = args[0]
if (control_file)
  rl = ACRO::ResultsList.new(control_file)
  rl.populate_with_results_files
  rl.write_to_file
  puts "Edit #{rl.file_name} with database flight idenifiers for the flights"
else
  puts 'Supply the name of the contest information file'
end
