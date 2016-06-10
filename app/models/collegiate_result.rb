class CollegiateResult < Result

def to_s
  "Collegiate Team #{name} #{year} #{result_percent}%"
end

def pilot_contests
  pilots = self.members.all # array of pilot members
  pilot_contests = {}
  pilots.each do |pilot|
    pilot_contests[pilot] = pilot.competitions(self.year)
  end
  pilot_contests
end

def self.find_or_create_team_for_year(team_name, year)
  team = CollegiateResult.where(:name => team_name, :year => year).first
  if (team == nil)
    team = CollegiateResult.create(:name => team_name, :year => year)
  end
  team
end

def self.list_collegiate_for_year(year)
  puts "#{year} Collegiate Teams Composition:"
  teams = CollegiateResult.where(:year => year)
  teams.each do |team|
    puts team
    team.members.each do |member|
      puts "\t#{member}"
    end
  end
end

end
