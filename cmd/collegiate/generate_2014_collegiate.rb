# To get the 2014 Collegiate results bootstrapped, we provide for your pleasure,
# this hard coded solution to editing the makeup of the teams.
# Someday soon!  We add administrative function to edit.
# Right now! We want result computations.
# Carry on.  We'll throw this out when we have the editing function in place.
class Generate_2014_Collegiate

def self.clear_the_boards
  CollegiateResult.where(year: 2014).destroy_all
end

def self.add_team(team_name)
  return CollegiateResult.create(name: team_name, year: 2014)
end

def self.find_team(team_name)
  return CollegiateResult.where(name: team_name, year: 2014).first
end

def self.check_add_member(team, member)
  team.members << member
end

def self.find_member(given, family, iac)
  Member.find_or_create_by_iac_number(iac, given, family)
end

def self.verify_for_that_warm_fuzzy_feeling
  teams = CollegiateResult.where(year: 2014)
  puts '2014 Collegiate Teams Composition:'
  teams.each do |team|
    puts team
    team.members.each do |member|
      puts "\t#{member}"
    end
  end
end

def self.initialize_roster
  team = add_team('United States Air Force Academy')
  check_add_member(team, find_member('Bradley','Belveal','437355'))
  check_add_member(team, find_member('Douglas','Clark','437351'))
  check_add_member(team, find_member('Dustin','Rivich','436928'))
  check_add_member(team, find_member('Henry','Leeuwenburg','436657'))
  check_add_member(team, find_member('Joseph','Gould','437353'))
  check_add_member(team, find_member('Joshua','Wilson','436656'))
  check_add_member(team, find_member('Matthew','Villanueva','436658'))
  check_add_member(team, find_member('Nicholas','Bode','437350'))
  check_add_member(team, find_member('Norman','Hitosis','437352'))
  check_add_member(team, find_member('Ryan','Combelic','436927'))
  check_add_member(team, find_member('Steel','Shoaf','437354'))

  team = add_team('Purdue University')
  check_add_member(team, find_member('Mitchell','Wild','433443'))

  team = add_team('University of North Dakota')
  check_add_member(team, find_member('Alexander','Sachs','436310'))
  check_add_member(team, find_member('Alexander','Volberding','437192'))
  check_add_member(team, find_member('Amelia','Gagnon','436756'))
  check_add_member(team, find_member('Cameron','Jaxheimer','436475'))
  check_add_member(team, find_member('Jennifer','Slack','436586'))
  check_add_member(team, find_member('Patrick','Mills','437204'))
  check_add_member(team, find_member('Rosemary','Coe','436830'))
  check_add_member(team, find_member('William','Sullivan','436817'))
  check_add_member(team, find_member('Wolfgang','Brink','437243'))
  check_add_member(team, find_member('Cortland','Dines','437143'))

  team = add_team('Embry Riddle Aeronautical University, Daytona')
  check_add_member(team, find_member('Alain','Aguayo','435356'))
  check_add_member(team, find_member('John','DeGennaro','437111'))
  check_add_member(team, find_member('Michael','Breshears','436478'))
  check_add_member(team, find_member('Cortland','Dines','437143'))

  team = add_team('Ventura College')
  check_add_member(team, find_member('Sam','Mason','435270'))
  check_add_member(team, find_member('Zachary','Corr','436954'))
end

clear_the_boards
initialize_roster
verify_for_that_warm_fuzzy_feeling

end
