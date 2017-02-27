module Contest::ShowResults
  def chief_names
    chiefs = []
    cfs = flights.all
    unless cfs.empty?
      cjs = cfs.collect do |flight|
        flight.chief
      end
      cjs = cjs.compact.uniq.sort do |a,b|
        a.family_name <=> b.family_name
      end
      chiefs = cjs.collect(&:name)
    end
    chiefs
  end
end

