# map the parsed XML JaSPer contest data
# into records of the contest database
# 'j' prefixes variables that contain JaSPer parsed data
# 'd' prefixes variables that reference the database madel
module Jasper
  class JasperToDB
    attr_accessor :d_contest

    # accept parsed XML JaSPer contest data
    # appropriately update or create records in the contest database
    # contest_id is the id for the contest created and assigned for 
    #   the posted data, but not recorded in the posted data, 
    #   when the data was posted
    # returns the contest
    def process_contest(jasper, contest_id = nil)
      @member_map = MemberMap.new
      contest_id = jasper.contest_id if contest_id == nil
      contest_params = extract_contest_params_hash(jasper)
      if (contest_id)
        @d_contest = updateOrCreateContest(contest_id, contest_params)
      else
        @d_contest = Contest.create!(contest_params)
      end
      if d_contest
        process_scores(d_contest, jasper)
        identify_collegiate_pilots(d_contest, jasper)
      end
      d_contest
    end

    def extract_contest_params_hash(jasper)
      contest_params = {};
      name = jasper.contest_name.strip.slice(0,48)
      contest_params['name'] = name.blank? ? 'missing contest name' : name
      contest_params['start'] = jasper.contest_date || Date.today
      contest_params['region'] = jasper.contest_region.strip.slice(0,16)
      contest_params['director'] = jasper.contest_director.strip.slice(0,48)
      contest_params['city'] = jasper.contest_city.strip.slice(0,24)
      contest_params['state'] = jasper.contest_state.strip.slice(0,2).upcase
      contest_params['chapter'] = jasper.contest_chapter
      contest_params
    end

    def updateOrCreateContest(id, contest_params)
      begin
        d_contest = Contest.find(id)
        d_contest.reset_to_base_attributes
        d_contest.update_attributes(contest_params)
      rescue ActiveRecord::RecordNotFound
        d_contest = Contest.create!(contest_params)
      end
      d_contest
    end

    def identify_collegiate_pilots(d_contest, jasper)
      cp = CollegiateParticipants.new(d_contest.year)
      cp.process_jasper(jasper)
    end

    def process_scores(d_contest, jasper)
      aircat = jasper.aircat
      jasper.categories_scored.each do |jCat|
        dCategory = category_for(jasper, aircat, jCat)
        process_category(jasper, dCategory, jCat)
      end
    end

    def process_pilot_flight(dFlight, jasper, jCat, jFlt, jPilot)
      dPilot = pilot_for(jasper, jCat, jPilot)
      dAirplane = airplane_for(jasper, jCat, jPilot)
      dSequence = sequence_for(jasper, jCat, jFlt, jPilot)
      dPilotFlight = pilot_flight_for(dFlight, dPilot, dSequence, dAirplane,
        jasper, jCat, jFlt, jPilot)
      scores_found = false
      jasper.judge_teams(jCat, jFlt).each do |jJudgeTeam|
        dJudge = judge_for(jasper, jCat, jFlt, jJudgeTeam)
        dAssist = judge_assist_for(jasper, jCat, jFlt, jJudgeTeam)
        dJudgeTeam = judge_team_for(dJudge, dAssist)
        if process_grades(
            dJudgeTeam, dPilotFlight, dSequence,
            jasper, jCat, jFlt, jPilot, jJudgeTeam)
          scores_found = true
        end
      end
      dPilotFlight.destroy! unless scores_found
      scores_found
    end

    def process_flight(jasper, flight_pilots, dCategory, jCat, jFlt)
      scores_found = false
      dFlight = flight_for(d_contest, dCategory, jasper, jCat, jFlt)
      flight_pilots.each do |jPilot|
        if process_pilot_flight(dFlight,
            jasper, jCat, jFlt, jPilot)
          scores_found = true
        end
      end
      dFlight.destroy! unless scores_found
    end

    def process_category(jasper, dCategory, jCat)
      jasper.flights_scored(jCat).each do |jFlt|
        flight_pilots = jasper.pilots_scored(jCat, jFlt)
        if 0 < flight_pilots.length
          process_flight(jasper, flight_pilots, dCategory, jCat, jFlt)
        end
      end
    end

    def category_for(jasper, aircat, jCat)
      category_name = jasper.category_name(jCat)
      cat = Category.find_for_cat_aircat(category_name, aircat)
      if !cat
        raise "JaSPer data invents a new category #{category_name}, #{aircat}"
      end
      cat
    end

    def flight_for(d_contest, dCategory, jasper, jCat, jFlt)
      chief = chief_for(jasper, jCat, jFlt)
      assist = chief_assist_for(jasper, jCat, jFlt)
      dFlight = dCategory.flights.find_by(contest: d_contest, sequence: jFlt)
      unless dFlight
        dFlight = d_contest.flights.build(
          :name => jasper.flight_name(jFlt),
          :sequence => jFlt,
          :chief_id => chief.id,
          :assist_id => assist.id
        )
        dFlight.categories << dCategory
        dFlight.save!
      end
      dFlight
    end

    def member_for(iac_id, given_name, family_name)
      # we assume a member with the same given_name and family_name
      # is the same person at any given contest
      # somewhat safe assumption that there aren't two "Tom Jones"
      # the find_or_create_by_name method correctly assumes that if there
      # are two "Tom Jones", they might be two different people.
      # we return the same "Tom Jones" member on every lookup
      family_name = '' if family_name.blank?
      family_name.gsub(/\(patch\)/i,'').strip
      given_name = '' if given_name.blank?
      given_name = given_name.strip
      member = @member_map.lookup(iac_id, given_name, family_name)
      if (member == nil)
        if (0 < iac_id.to_i)
          member = Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
        else
          member = Member.find_or_create_by_name(iac_id, given_name, family_name)
        end
        @member_map.insert(iac_id, given_name, family_name, member)
      end
      member
    end

    def chief_for(jasper, jCat, jFlt)
      member_for(jasper.chief_iac_number(jCat, jFlt),
        jasper.chief_first_name(jCat, jFlt),
        jasper.chief_last_name(jCat, jFlt))
    end

    def chief_assist_for(jasper, jCat, jFlt)
      member_for(
        jasper.chief_assist_iac_number(jCat, jFlt),
        jasper.chief_assist_first_name(jCat, jFlt),
        jasper.chief_assist_last_name(jCat, jFlt))
    end

    def pilot_for(jasper, jCat, jPilot)
      member_for(jasper.pilot_iac_number(jCat, jPilot),
        jasper.pilot_first_name(jCat, jPilot),
        jasper.pilot_last_name(jCat, jPilot))
    end

    def pilot_is_hc(jasper, jCat, jPilot)
      jasper.pilot_is_hc(jCat, jPilot)
    end

    def airplane_for(jasper, jCat, jPilot)
      Airplane.find_or_create_by_make_model_reg(jasper.airplane_make(jCat, jPilot),
        jasper.airplane_model(jCat, jPilot),
        jasper.airplane_reg(jCat, jPilot))
    end

    def judge_for(jasper, jCat, jFlt, jJudgeTeam)
      member_for(
        jasper.judge_iac_number(jCat, jFlt, jJudgeTeam),
        jasper.judge_first_name(jCat, jFlt, jJudgeTeam),
        jasper.judge_last_name(jCat, jFlt, jJudgeTeam))
    end

    def judge_assist_for(jasper, jCat, jFlt, jJudgeTeam)
      member_for(
        jasper.judge_assist_iac_number(jCat, jFlt, jJudgeTeam),
        jasper.judge_assist_first_name(jCat, jFlt, jJudgeTeam),
        jasper.judge_assist_last_name(jCat, jFlt, jJudgeTeam))
    end

    def judge_team_for(dJudge, dAssist)
      dJudgeTeam = Judge.find_by_judge_id_and_assist_id(dJudge.id, dAssist.id)
      if (dJudgeTeam == nil)
        dJudgeTeam = Judge.create!(judge_id: dJudge.id, assist_id: dAssist.id)
      end
      dJudgeTeam
    end

    def sequence_for(jasper, jCat, jFlt, jPilot)
      ks_string = jasper.k_values_for(jCat, jFlt, jPilot)
      ks = ks_string.split.map { |k_s| k_s.to_i }
      ks = ks.select { |k| k != 0 }
      Sequence.find_or_create(ks)
    end

    def pilot_flight_for(dFlight, dPilot, dSequence, dAirplane, jasper, jCat, jFlt, jPilot)
      pf = PilotFlight.where(flight_id: dFlight.id, pilot_id: dPilot.id).first
      if pf.blank?
        pf = PilotFlight.create!(
          :flight_id => dFlight.id,
          :pilot_id => dPilot.id,
          :sequence_id => dSequence.id,
          :airplane_id => dAirplane.id,
          :chapter => jasper.pilot_chapter(jCat, jPilot),
          :penalty_total => jasper.penalty(jCat, jFlt, jPilot),
        ) do |pf|
          if jasper.pilot_is_hc(jCat, jPilot)
            pf.hc_higher_category.save!
          end
        end
      end
      return pf
    end

    def process_grades(dJudgeTeam, dPilotFlight, dSequence,
        jasper, jCat, jFlt, jPilot, jJudgeTeam)
      grades_string = jasper.grades_for(jCat, jFlt, jPilot, jJudgeTeam)
      # can get empty grades
      if !grades_string.empty?
        grades = grades_string.split
        grades = grades.map { |g| (g.to_f * 10.0).round }
        grades = remove_extraneous_grades(grades, jCat, dSequence.figure_count)
        dPilotFlight.scores.create!(
          :judge_id => dJudgeTeam.id,
          :values => grades)
      end
      !grades_string.empty?
    end

    def remove_extraneous_grades(grades, jCat, ctFigures)
      if 0 < ctFigures
        if (jCat == 6) # four minute
          abbrev = grades[0, ctFigures]
        else
          abbrev = grades[0, ctFigures - 1]
          abbrev << grades.last
        end
      else
        grades
      end
    end
  end
end
