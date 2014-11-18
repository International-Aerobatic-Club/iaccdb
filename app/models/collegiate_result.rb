class CollegiateResult < Result

def to_s
  "Collegiate Team #{name} #{year} #{result_percent}%"
end

def pilot_contests
  pilots = self.members.all # array of pilot members
  pilot_contests = {}
  pilots.each do |pilot|
    pilot_contests[pilot] = pilot.contests(self.year)
  end
  pilot_contests
end

end
