module IAC

  class CollegiateTeamComputer

    class Result
      attr_accessor :total
      attr_accessor :total_possible
      attr_accessor :combination
      attr_accessor :qualified
      attr_accessor :has_non_primary

      def initialize
        @total = 0.0
        @total_possible = 0
        @combination = []
        @qualified = false
        @has_non_primary = false
      end

      def self.dup(result)
        dup = Result.new
        dup.total = result.total
        dup.total_possible = result.total_possible
        dup.combination = Array.new(result.combination)
        dup.qualified = result.qualified
        dup.has_non_primary = result.has_non_primary
        dup
      end

      def value
        self.total_possible != 0 ? self.total / self.total_possible : 0
      end

      def <(other)
        self.value < other.value
      end

      def to_s
        s = "#{sprintf('%0.2f', value * 100.0)}\n"
        combination.each do |c|
          s << "\t#{c.pilot.iac_id} #{c.contest.name}\n"
        end
        s
      end

    end  # class Result

    # pilot_contests is hash pilot => pc_results
    def initialize(pilot_contests)
      @pilot_contests = pilot_contests
      @pilots = @pilot_contests.keys
      # disregard pilots with no contest participation
      @pilots.delete_if { |pilot| @pilot_contests[pilot].size == 0 }
      initialize_counts
    end

    # Calculate the results for one collegiate team
    # First, determine eligibility for the Team Award per P&P 225.7.1(d,e,g)
    # Then compute the team's best result per 225.7.1(h), even if the team is not (yet) eligible for the Team Award
    def compute_result

      result = Result.new

      # Gather the Category#id values that count towards the Team Award
      # Note that there are two Category objects per competition level: one for Power and one for Gliders
      all_cats = Category.where(category: %w[ primary sportsman intermediate ])
      upper_cats = Category.where(category: %w[ sportsman intermediate ])

      # Find all pilots who flew "enough" contests in any allowed category
      qualifying_pilots = @pilots.find_all{ |p| flew_enough?(p, all_cats) }

      # Find all pilots who flew "enough" contests in Spt/Int
      qualifying_uppers = @pilots.find_all{ |pilot| flew_enough?(pilot, upper_cats) }

      # A team is qualified if there are at least three qualifying pilots and one upper-category qualifier
      result.qualified = (qualifying_pilots.size >= 3 && qualifying_uppers.size > 0)

      # Of the upper-category qualifiers, find the one with the highest average for their 3 best
      # results in one of those categories (P&P 225.7.1(h)(1))
      best_upper_pilot = qualifying_uppers.map do |qs|
        bcs = best_contests(qs, upper_cats).first(3)
        { pilot: qs, avg_pp: bcs.map(&:pct_possible).sum / 3, pilot_contests: bcs}
      end.sort_by{ |h| -h[:avg_pp] }.first

      # We remove the best upper-category pilot from the list of all qualifying pilots so that
      # they are not counted a second time when we evaluate the remaining results
      qualifying_pilots.delete(best_upper_pilot[:pilot]) if best_upper_pilot.present?

      # Of the remaining qualifying pilots, get the average of their three best contests,
      # then take two pilots with the best averages
      best_others = qualifying_pilots.map do |qp|
        bcs = best_contests(qp, all_cats).first(3)
        { pilot: qp, avg_pp: bcs.map(&:pct_possible).sum / 3, pilot_contests: bcs }
      end.sort_by{ |h| -h[:avg_pp] }.first(2)

      # Now combine the best upper-category pilot with the other two best pilots,
      # squeeze out any nil results (which will occur if there is no "best Sportsman"
      # or less than two other qualifiers), and sort by their %pp
      top3_pilots = ([ best_upper_pilot ] + best_others).compact.sort_by{ |h| -h[:avg_pp] }

      # Now average them
      result.total = top3_pilots.empty? ? 0 : top3_pilots.map{ |h| h[:avg_pp] }.sum / top3_pilots.size

      # Because we calculate scores as percentages, the maximum possible is always 100
      result.total_possible = 100

      # Save the PcResult objects
      result.combination = top3_pilots.map{ |h| h[:pilot_contests] }.flatten

      return result

    end


    ###
    private
    ###

    def flew_enough?(pilot, categories)
      @pilot_contests[pilot].where(category: categories).count >= 3
    end

    def best_contests(pilot, categories)
      @pilot_contests[pilot].where(category: categories).sort_by{ |pcr| -pcr.pct_possible }
    end

    def initialize_counts
      contests_properties = gather_contest_properties(@pilot_contests)
      @non_primary_participant_occurrence_count = 0
      @three_or_more_pilot_occurrence_count = 0
      contests_properties.each do |contest|
        @non_primary_participant_occurrence_count += 1 if contest[:has_non_primary]
        @three_or_more_pilot_occurrence_count += 1 if 3 <= contest[:pilot_count]
      end

      # Count of pilots participating is three or more and
      # Three contests with three pilots and
      # Three contests with at least one non-Primary pilot
      @is_qualified =
        3 <= @non_primary_participant_occurrence_count &&
        3 <= @three_or_more_pilot_occurrence_count
    end

    # pilot_contests is hash of pilot (member)  => [ array of pc_result ]
    # return an array of hashes, one for each unique contest found in pilot_contests
    # each hash contains keys:
    #   :has_non_primary boolean true if one pilot flew the contest not in Primary
    #   :pilot_count integer count of pilots who flew in the contest
    def gather_contest_properties(pilot_contests)

      contest_props = {}

      pilot_contests.each_pair do | pilot, pc_results |

        pc_results.each do | pc_result |
          contest = pc_result.contest
          props = contest_props[contest]
          if !props
            props = { :has_non_primary => false, :pilot_count => 0 }
            contest_props[contest] = props
          end
          props[:pilot_count] += 1
          if !pc_result.category.is_primary
            props[:has_non_primary] = true
          end
        end

      end

      contest_props.values

    end

  end  # class CollegiateTeamComputer

end  # module IAC
