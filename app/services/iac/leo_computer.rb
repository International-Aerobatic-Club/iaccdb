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

    # Minimum number of unique regions required to be qualified
    REGIONS_REQD = 3


    def initialize(year)
      @year = year.to_i
    end

    def recompute

      # Arrays of all results
      pc_results = Array.new

      # Get all categories that contend for the Leo Award
      # We save the query results in an Array to avoid numerous ActiveRecord queries in the logic that follows
      categories = LeoRank.categories(@year)


      ### STEP 1 ###
      # Preliminary setup

      # Get the highest Category#sequence value for each pilot who completed during the prior two years (P&P 227.2.3.5)
      pilot_minimum_category = PcResult
        .joins(:contest, :category)
        .where('YEAR(contests.start) >= ?', @year - 2)
        .where('YEAR(contests.start) < ?', @year + 1)
        .where(category: categories)
        .group(:pilot_id)
        .maximum('categories.sequence')

      # Get all domestic (US & Canada) contests
      contests = Contest.where('YEAR(start) = ?', @year).where(state: US_STATE_ABBREVS)

      # Cache pilot names
      pilot_names = Member.where(id: pilot_minimum_category.keys).map{ |m| [m.id, m.name] }.to_h



      ###### STEP 2 ######
      # Create an Array of PcResult records for the contests and categories for the year in question

      # Iterate over all PcResult records
      PcResult.includes(:category, :contest).where(contest: contests, category: categories).each do |pcr|

        # Convert the ActiveRecord::Base object to a Hash, allowing us to add pseudo-attributes as processing proceeds
        record = pcr.as_json.with_indifferent_access

        # Change region 'Nationals' to the actual physical region where the Nationals contest is hold
        record[:region] = fix_nats(pcr.contest.region)
        record[:category] = pcr.category.category

        # The pilot is qualified if they are not HC and competing in their minimum category or higher
        record[:qualified] =
          pcr.hors_concours.zero? && pcr.category.sequence >= (pilot_minimum_category[pcr.pilot_id] || 0)

        # Save the PcResult
        pc_results << record

      end  # PcResult.includes



      ###### STEP 3 ######
      # Calculate the percentile rank for each qualified flight

      # Now we iterate over the results again because we need to know how many unqualified pilots there are,
      # and how many of them finished higher a given qualified pilot.
      pc_results.each do |pcr|

        # Count all pilots, all unqualified pilots, and all unqualified pilots with a better ranking
        # who participated in the same contest and category
        total_pilots = total_unqualified = unqualifieds_ahead = 0

        pc_results.find_all do |r|

          # Match the contest and category
          next unless r[:contest_id] == pcr[:contest_id] && r[:category_id] == pcr[:category_id]

          total_pilots += 1

          unless r[:qualified]
            total_unqualified += 1
            unqualifieds_ahead += 1 if r[:category_rank] < pcr[:category_rank]
          end

        end  # pc_results.each


        # Subtract total unqualified pilots from total pilots
        adjusted_total = total_pilots - total_unqualified

        # Subtract any unqualified pilots who finished with a better rank than the competitor
        adjusted_rank = pcr[:category_rank] - unqualifieds_ahead

        # Calculate the percentile rank using the adjusted rank & total count
        pcr[:percentile_rank] = (1 - (adjusted_rank / (adjusted_total.to_f + 1))) * 100

      end




      ###### STEP 4 ######
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
          # !!! HACK !!!
          # Set `LeoPilotContest#rank` to 1 to indicate a flight that went into the Avg. Percentile
          # The `is_a?(String)` test is needed because a different hack saves the average percentile
          # score in the same array as the LPCs
          pilots_best[category][pilot_id].each_pair{ |key, r| r[:rank] = 1 if key.is_a?(String) }
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

        pc_results.each do |pcr|

          # Convenience var
          contest = Contest.find(pcr['contest_id'])

          # Persist the results
          LeoPilotContest.create(
            year: @year,
            category_id: pcr[:category_id],
            pilot_id: pcr[:pilot_id],
            # !!! HACKS !!!
            # The view needs several Contest attributes, so I save the `contest#id` value in the `name` attr
            name: contest.id,
            rank: pcr[:rank],
            # !!! END OF HACKS !!!
            region: fix_nats(contest.region),
            qualified: pcr[:qualified],
            points: pcr[:percentile_rank],
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
            index_start = (qual == :qualified ? 1 : leo_ranks[:qualified][category].size + 1)
            ranks.map.with_index(index_start) do |(pilot_id, rank), i|

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
      region == 'National' ? 'SouthCentral' : region
    end

  end  # Class

end  # Module
