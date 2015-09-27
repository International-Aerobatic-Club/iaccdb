# Add or remove a collegiate team member
# Use rails runner, 
#   e.g. 'rails r cmd/collegiate/edit_collegiate_participation.rb'
# No parameters gives usage
class EditCollegiateParticipation
  attr_accessor :year

  def initialize(year)
    @year = year
  end

  def remove(iac_id)
    puts "Removing IAC \##{iac_id} in #{year}"
    member = Member.where(iac_id: iac_id).first
    if (member)
      puts "#{member.given_name} #{member.family_name}"
      teams = CollegiateResult.where(year: year)
      teams.each do |team|
        rm = ResultMember.where(result: team, member: member).first
        if (rm)
          team.result_members.destroy(rm)
          puts "\tRemoved from #{team}"
        end
      end
    else
      puts "No member record with that IAC ID"
    end
  end

  def add(team_name, iac_id, given_name, family_name)
    puts "Adding #{given_name} #{family_name}, IAC \##{iac_id} to '#{team_name}' in #{year}"
    member = Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
    if (member)
      puts "#{member.given_name} #{member.family_name}"
      team = CollegiateResult.find_or_create_team_for_year(team_name, year)
      puts "Ensuring member of #{team}"
      team.add_member_if_not_present(member)
      team.save
    else
      puts "No member record with that IAC ID"
    end
  end

  def verify_for_that_warm_fuzzy_feeling
    teams = CollegiateResult.where(:year => year)
    puts "#{year} Collegiate Teams Composition:"
    teams.each do |team|
      puts team
      team.members.each do |member|
        puts "\t#{member}"
      end
    end
  end
end

def print_usage
  cur_year = Date.today.year
  puts "Add or remove a collegiate team member."
  puts "First parameter is the year"
  puts "Second paramater is the operation 'add' or 'remove'"
  puts " (may be abbreviated to the first letter)"
  puts "For remove, give the IAC ID"
  puts "  e.g. \"#{cur_year} remove 430157\""
  puts "For add, give the team name, IAC ID, first name, and last_name"
  puts "  e.g. \"#{cur_year} add 'United States Air Force Academy' 430157 Douglas Lovell\""
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
if (year == 0 || year < 1990 || ARGV.length < 2)
  print_usage
else
  ec = EditCollegiateParticipation.new(year)
  op = ARGV[1]
  if op[0] == 'r'
    if ARGV.length < 3
      puts "Missing IAC ID for remove."
      print_usage
    else
      ec.remove(ARGV[2])
    end
  elsif op[0] == 'a'
    if ARGV.length < 6
      puts "Missing parameters for add."
      print_usage
    else
      ec.add(ARGV[2], ARGV[3], ARGV[4], ARGV[5])
    end
  end
end

