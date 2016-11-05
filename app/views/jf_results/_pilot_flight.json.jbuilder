json.pilot do
  json.partial! 'members/member', member: pf.pilot
end
json.partial! 'sequence', sequence: pf.sequence
