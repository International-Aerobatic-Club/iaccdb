# Print the Contest, Type (power vs glider), Category, and Pilot for any Free sequences
# whose total figure K is less than the maximum allowable.
#
# Also flag any Frees whose figure K *exceeds* the allowable max... as long as we're at it. :-)
#
# DJM, 2020-10-18

MAX_KS = {
  'P' => {
    'sportsman' => {
      2006 => 127,
      2007 => 132,
      2008 => 135,
      2009 => 125,
      2010 => 137,
      2011 => 127,
      2012 => 124,
      2013 => 149,
      2014 => 136,
      2015 => 130,
      2016 => 126,
      2017 => 133,
      2018 => 121,
      2019 => 119,
      2020 => 129
    },
    'intermediate' => 190,
    'advanced' => 300,
    'unlimited' => 420
  },
  'G' => {
    'sportsman' => {
      2006 => 128,
      2007 => 125,
      2008 => 102,
      2009 =>  94,
      2010 => 113,
      2011 => 124,
      2012 => 127,
      2013 => 127,
      2014 => 106,
      2015 => 117,
      2016 =>  96,
      2017 => 140,
      2018 => 103,
      2019 => 121,
      2020 =>  94
    },
    'intermediate' => 140,
    'advanced' => 175,
    'unlimited' => 230
  }
}

CATEGORIES = %w{ sportsman intermediate advanced unlimited }

FREE_SEQ = 2  # JaSPer / IACCDB numbering convention for the Free program



%w{ P G }.each do |aircat|

  CATEGORIES.each do |category|

    puts "*********** #{category} / #{aircat}"

    Flight.joins(:categories).merge(Category.where(aircat: aircat, category: category)).where(name: 'Free').each do |flight|

      c = flight.contest

      next if c.start.year < 2009 || [11, 153, 159, 261].index(c.id)

      if category == 'sportsman'
        max_allowable_k = MAX_KS[aircat][category][flight.contest.start.year]
      else
        max_allowable_k = MAX_KS[aircat][category]
      end

      # For each pilot...
      flight.pilot_flights.each do |pf|

        # Some PilotFlight records have no associated sequence
        next if pf.sequence.nil?

        # Add up the figure K's, which are all entries in the k_values array except for the last one
        seq_k = pf.sequence.k_values[0..-2].sum

        # Some flights don't have an associated category
        next if flight.category.nil?

        p = pf.pilot
        next if p.nil?

        c = flight.contest

        # Special case
        if aircat == 'G' && category == 'advanced' && c.start.year < 2014
          max_allowable_k = 160
        end

          if seq_k > max_allowable_k
          puts "TOO MUCH K! Contest ##{c.id} (#{c.start.year}), " +
                 "Type: #{aircat}, Category: #{flight.category.category}, Pilot: #{p.name}"
        elsif seq_k < max_allowable_k
          puts "Too little K: Contest ##{c.id} (#{c.start.year}), " +
                 "Type: #{aircat}, Category: #{flight.category.category}, Pilot: #{p.name}"
        end

      end

    end # Flight.joins

  end

  puts "\n\n\n"

end
