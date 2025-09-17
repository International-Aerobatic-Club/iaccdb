module IAC

  class CollegiateTeamComputer


    ## Constants
    # Number of pilots who count towards a school's rankings
    N_TOP = 3
    # Minimum number of contests a pilot must have participated in to qualify
    MIN_CONTESTS = 3

    class Result
      attr_accessor :total
      attr_accessor :total_possible
      attr_accessor :combination
      attr_accessor :qualified

      def initialize
        @total = 0.0
        @total_possible = 0
        @combination = []
        @qualified = false
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
      # Find all pilots who flew at least one contest
      @pilots = @pilot_contests.keys.find_all{ |pilot| @pilot_contests[pilot].present? }
    end

    # Calculate the results for one collegiate team
    # First, determine eligibility for the Team Award per P&P 225.7.1(d,e,g)
    # Then compute the team's best result per 225.7.1(h), even if the team is not (yet) eligible for the Team Award
    def compute_result

      result = Result.new

      # Gather the Categories that count towards the Team Award
      # Note: there are two Category objects per competition level: one for Power and one for Gliders
      collegiate_cats = Category.where(category: %w[ primary sportsman intermediate ])
      sportsman_cats = Category.where(category: 'sportsman')

      best_sportsman_pilot =
        @pilots.find_all{ |p| flew_enough?(p, sportsman_cats) }.sort_by{ |p| -ppa(p, sportsman_cats) }.first

      best_sportsman_info =
        if best_sportsman_pilot.present?
          {
            pilot: best_sportsman_pilot,
            avg_pp: ppa(best_sportsman_pilot, sportsman_cats),
            pilot_contests: best_contests(best_sportsman_pilot, sportsman_cats)
          }
        else
          nil
        end

      # Find all remaining pilots who flew "enough" contests in any allowed category
      qualifying_pilots = @pilots.find_all{ |p| p != best_sportsman_pilot && flew_enough?(p, collegiate_cats) }

      # Find the best qualified Sportsman pilot, if any
      # A team is qualified if there are at least N_TOP qualifying pilots, including a qualified Sportsman pilot
      result.qualified = (qualifying_pilots.size >= N_TOP - 1 && best_sportsman_pilot.present?)

      # For each qualifying pilot, get the average of their MIN_CONTESTS best results
      best_others = qualifying_pilots.map do |qp|
        { pilot: qp, avg_pp: ppa(qp, collegiate_cats), pilot_contests: best_contests(qp, collegiate_cats) }
      end.sort_by{ |h| -h[:avg_pp] }

      # Now combine the best Sportsman pilot with the other best pilots,
      # squeeze out any nil results (which will occur if there is no "best Sportsman"
      # or not enough other qualifiers), and sort by their %pp
      top_n_pilots = ([ best_sportsman_info ] + best_others).compact.sort_by{ |h| -h[:avg_pp] }.first(N_TOP)

      # Now average them
      result.total = top_n_pilots.present? ? top_n_pilots.map{ |h| h[:avg_pp] }.sum / top_n_pilots.size : 0.0

      # Because we calculate scores as percentages, the maximum possible is always 100
      result.total_possible = 100

      # Save the PcResult objects
      result.combination = top_n_pilots.map{ |h| h[:pilot_contests] }.flatten

      return result

    end


    private

    def flew_enough?(pilot, categories)
      @pilot_contests[pilot].where(category: categories).count >= MIN_CONTESTS
    end


    def best_contests(pilot, categories)
      @pilot_contests[pilot]&.where(category: categories).sort_by{ |pcr| -pcr.pct_possible }
    end


    def ppa(pilot, categories)

      # Get the pilot's best contests in the eligible categories
      bcs = best_contests(pilot, categories).first(MIN_CONTESTS)

      return 0.0 if bcs.size.zero?

      # Divide the total possible by the minimum number of contests or total contests flown, whichever is less
      return bcs.first(MIN_CONTESTS).map(&:pct_possible).sum / [MIN_CONTESTS, bcs.size].min

    end


    # pilot_contests is hash of pilot (member)  => [ array of pc_result ]
    # return an array of hashes, one for each unique contest found in pilot_contests
    # each hash contains keys:
    #   :pilot_count integer count of pilots who flew in the contest
    def gather_contest_properties(pilot_contests)

      contest_props = {}

      pilot_contests.values do |pc_results|

        pc_results.each do | pc_result |
          contest = pc_result.contest
          props = contest_props[contest]
          if props.empty?
            props = { pilot_count: 0 }
            contest_props[contest] = props
          end
          props[:pilot_count] += 1
        end

      end

      contest_props.values

    end

  end  # class CollegiateTeamComputer

end  # module IAC
