module ACRO
module PsychYamlWorkaround
  ## This line is a workaround.
  # Without it, the psych YAML parser does not know how to 
  # find the classs, it emits,
  # "undefined class/module ACRO::PilotFlightData"
  pfl = PilotFlightData.new
  # If you comment it out and the code still works, then
  # the problem has been fixed and you can delete this long-winded
  # workaround message.
  ## End workaround.
end
end

