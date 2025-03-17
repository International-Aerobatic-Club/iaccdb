# National Point Series calculations, see:
#   https://www.iac.org/minutes/policy-and-procedure-manual, P&P 227
#   https://www.iac.org/national-point-series-championship-iac-npsc

module IAC

  class LeoComputer

    # Minimum number of regions to qualify
    REGIONS_REQD = 3

    # The top 'n' percentile rankings are averaged
    BEST_N_RANKS = 3


    def initialize(year)
      @year = year.to_i
    end

    def recompute

      # Arrays of all results
      pc_results = Array.new

      # Get all categories that qualify for the Leo
      categories = Category.where(aircat: 'P', synthetic: false)


      ### STEP 1 ###
      # Preliminary setup

      # Get the highest Category#sequence value for each pilot who completed during the prior two years (P&P 227.2.3.5)
      pilot_minimum_category = PcResult
        .joins(:contest, :category)
        .where('YEAR(contests.start) IN (?,?)', @year - 2, @year - 1)
        .where(category: categories)
        .group(:pilot_id)
        .maximum('categories.sequence')

      # Get all domestic (US & Canada) contests
      contests = Contest.where('YEAR(start) = ?', @year).where.not(region: 'International')

      # Cache pilot names
      pilot_names = Member.where(id: pilot_minimum_category.keys).map{ |m| [m.id, m.name] }.to_h



      ###### STEP 2 ######
      # Enforce misc. eligibility rules and calculate the percentile rank for each eligible flight

      # Iterate over all PcResult records for the contests and categories covered by the Leo rules
      PcResult.includes(:category, :contest).where(contest: contests, category: categories).each do |pcr|

        # Convert the ActiveRecord::Base object to a Hash, allowing us to add pseudo-attributes as processing proceeds
        record = pcr.as_json.with_indifferent_access

        # Exception: Treat the 'National' region as SouthCentral. This may need to be changed, with a date cutoff,
        # if Nationals ever moves to a different region.
        record[:region] = (pcr.contest.region == 'National' ? 'SouthCentral' : pcr.contest.region)
        record[:category] = pcr.category.category

        # If the pilot is competing in less than their minimum category, mark them ineligible
        if pcr.category.sequence < (pilot_minimum_category[pcr.pilot_id] || 0)
          record[:ineligible_reason] = 'Competed in a higher category within the prior two years'
          record[:qualified] = false
        # Mark HC competitors as ineligible
        elsif pcr.hors_concours.positive?
          record[:ineligible_reason] = 'Competed as HC'
          record[:qualified] = false
        # Pilots who are alone in their category get a fixed rank of 50.
        elsif (pcr_count = PcResult.where(contest: pcr.contest, category: pcr.category, hors_concours: 0).count) == 1
          record[:percentile_rank] = 50.0
          record[:qualified] = true
        else
          # Calculate the percentile rank
          record[:percentile_rank] = (1 - (pcr.category_rank * (1/(pcr_count.to_f + 1)))) * 100
          record[:qualified] = true
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
      pilots_best.each_value do |pilots|
        pilots.each_pair do |pilot, regions|
          pilot[:percentile_avg] = (regions.values.map{ |h| h[:percentile_rank] }.sum / BEST_N_RANKS).round(2)
        end
      end



      ###### STEP 6 ######
      # Write the individual pilot-contest-category results to the database

      # All or nothing
      # TODO: Add error reporting if `#transaction` returns `false`
      ActiveRecord::Base.transaction do

        # Erase existing records for the year in question
        LeoPilotContest.where(year: @year).delete_all

        pc_results.each do |result|

          LeoPilotContest.new(
            year: @year,
            category_id: result[:category_id],
            pilot_id: result[:pilot_id],
            region: 'National',
            name: pilot_names[result[:pilot_id]],
            qualified: result[:qualified],
            rank: 0, # Placeholder; ranking is done below and stored as LeoRank objects
            points: result[:percentile_rank],
            points_possible: 100,
            ).save

        end  # results.each

      end  # transaction

    end  # def recompute

  end  # Class

end  # Module
