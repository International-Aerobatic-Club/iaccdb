# National Point Series calculations, see:
#   https://www.iac.org/minutes/policy-and-procedure-manual, P&P 227
#   https://www.iac.org/national-point-series-championship-iac-npsc

module IAC

  class LeoComputer

    US_STATE_ABBREVS =
      %w(
        AL AK AZ AR CA CO CT DE FL GA HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO
        MT NE NV NH NJ NM NY NC ND OH OK OR PA RI SC SD TN TX UT VT VA WA WV WI WY
      )

    # Minimum number of regions to qualify
    REGIONS_REQD = 3


    def initialize(year)
      @year = year.to_i
    end

    def recompute

      # Arrays of all results
      pc_results = Array.new

      # Get all categories that qualify for the Leo Award
      # We save the query results in an Array to avoid numerous ActiveRecord queries in the logic that follows
      categories = LeoRank.categories


      ### STEP 1 ###
      # Preliminary setup

      # Get the highest Category#sequence value for each pilot who completed during the prior two years (P&P 227.2.3.5)
      pilot_minimum_category = PcResult
        .joins(:contest, :category)
        .where('YEAR(contests.start) >= ?', Date.today.year - 2)
        .where(category: categories)
        .group(:pilot_id)
        .maximum('categories.sequence')

      # Get all domestic (US & Canada) contests
      contests = Contest.where('YEAR(start) = ?', @year).where(contests: { state: US_STATE_ABBREVS })

      # Cache pilot names
      pilot_names = Member.where(id: pilot_minimum_category.keys).map{ |m| [m.id, m.name] }.to_h



      ###### STEP 2 ######
      # Enforce misc. eligibility rules and calculate the percentile rank for each eligible flight

      # Iterate over all PcResult records for the contests and categories covered by the Leo rules
      PcResult.includes(:category, :contest).where(contest: contests, category: categories).each do |pcr|

        # Convert the ActiveRecord::Base object to a Hash, allowing us to add pseudo-attributes as processing proceeds
        record = pcr.as_json.with_indifferent_access

        # if Nationals ever moves to a different region.
        record[:region] = fix_nats(pcr.contest.region)
        record[:category] = pcr.category.category

        # If the pilot is competing in less than their minimum category, mark them ineligible
        if pcr.category.sequence < (pilot_minimum_category[pcr.pilot_id] || 0)
          record[:ineligible_reason] = 'Competed in a higher category within the prior two years'
          record[:qualified] = false
        # Mark HC competitors as ineligible
        elsif pcr.hors_concours.positive?
          record[:ineligible_reason] = 'Competed as HC'
          record[:qualified] = false
        else
          record[:qualified] = true
        end

        # Pilots who are alone in their category get a fixed rank of 50.
        if (pcr_count = PcResult.where(contest: pcr.contest, category: pcr.category, hors_concours: 0).count) == 1
          record[:percentile_rank] = 50.0
        else
          # Calculate the percentile rank
          record[:percentile_rank] = (1 - (pcr.category_rank * (1/(pcr_count.to_f + 1)))) * 100
        end

        # Save the PcResult
        pc_results << record

      end  # PcResult.includes



      ###### STEP 3 ######
      # Rank the pilots and determine who has qualified for the award by meeting the three-region minimum,
      # and store up to three best region scores for each pilot.

      pilots_best = Hash.new

      # Iterate over the qualified results for that year and category
      pc_results.find_all{ |r| r[:qualified] }.each do |pcr|

        pilots_best[pcr[:category]] ||= Hash.new
        pilots_best[pcr[:category]][pcr[:pilot_id]] ||= Hash.new

        # Convenience var
        pb = pilots_best[pcr[:category]][pcr[:pilot_id]]

        # If we haven't saved the pilot's results for the region in question...
        if pb[pcr[:region]].blank?

          # And if there are less than REGIONS_REQD regions saved overall, keep this record
          if pb.size < REGIONS_REQD
            pb[pcr[:region]] = pcr
          # We've already filled the region slots; see if `pcr[:percentile_rank]` is greater than
          # the lowest rank in `pilots_best`
          elsif pcr[:percentile_rank] > (worst_pct = pb.values.map{ |h| h[:percentile_rank] }.min)
            # Delete the region with the worst percentile rank
            pb.delete pb.values.find{ |r| r[:percentile_rank] == worst_pct }[:region]
            # And replace it with the current record
            pb[pcr[:region]] = pcr
          end

        # If we already have a result for the region in question; if its percentile rank is lower than
        # the current record, replace it with the current record,
        elsif pb[pcr[:region]].present? && pb[pcr[:region]][:percentile_rank] < pcr[:percentile_rank]
          pb[pcr[:region]] = pcr
        end

      end



      ###### STEP 5 ######
      # Compute the average percentile per pilot
      pilots_best.each_pair do |category, pilots|
        pilots.each_pair do |pilot_id, regions|
          pct_values = regions.values.map{ |h| h[:percentile_rank] }
          pilots_best[category][pilot_id][:percentile_avg] = (pct_values.sum / pct_values.size).round(2)
        end
      end



      ###### STEP 6 ######
      # Rank the pilots in each category

      leo_ranks = Hash.new
      leo_ranks[:qualified] = Hash.new
      leo_ranks[:unqualified] = Hash.new

      pilots_best.each_pair do |category, pilots|

        leo_ranks[:qualified][category] = Array.new
        leo_ranks[:unqualified][category] = Array.new

        pilots.sort_by{ |pilot_id, regions| -regions[:percentile_avg] }.each do |pilot_id, regions|
          qual = (regions.size == REGIONS_REQD + 1 ? :qualified : :unqualified)
          leo_ranks[qual][category] << [pilot_id, regions[:percentile_avg]]
        end

      end



      ###### STEP 7 ######
      # Write the individual pilot-contest-category results to the database

      # TODO: Add error reporting if `#transaction` returns `false`; see GitHub issue #268
      # All or nothing
      ActiveRecord::Base.transaction do

        # Erase any Leo records for the year in question
        LeoPilotContest.where(year: @year).delete_all
        LeoRank.where(year: @year).delete_all

        pc_results.each do |result|

          LeoPilotContest.create(
            year: @year,
            category_id: result[:category_id],
            pilot_id: result[:pilot_id],
            name: pilot_names[result[:pilot_id]],
            region: fix_nats(Contest.find(result['contest_id']).region),
            qualified: result[:qualified],
            points: result[:percentile_rank],
            points_possible: 100,
          )

        end  # pc_results.each


        # Create the LeoRank records
        # Iterate over the qualified & unqualified lists separately
        leo_ranks.keys.each do |qual|

          # Iterate over the categories
          leo_ranks[qual].each_pair do |category, ranks|

            # All qualified pilots are ranked above unqualified pilots
            # We fiddle the starting index to force all qualified pilots to be ranked first, then the unqualified ones
            ranks.map.with_index(qual == :qualified ? 1 : leo_ranks[:qualified][category].size + 1) do |(pilot_id, rank), i|

              LeoRank.create(
                year: @year,
                category_id: categories.find{ |c| c.category == category }.id,
                pilot_id: pilot_id,
                name: pilot_names[pilot_id],
                region: 'National',
                qualified: qual == :qualified,
                rank: i,
                points: rank,
                points_possible: 100,
              )

            end  # ranks.with_index

          end  # categories.each_pair

        end  # leo_ranks.keys

      end  # transaction

    end  # def recompute


    private

    def fix_nats(region)
      region == 'Nationals' ? 'SouthCentral' : region
    end

  end  # Class

end  # Module
