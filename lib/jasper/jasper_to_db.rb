# assume loaded with rails ActiveRecord
# environment for IAC contest data application

# map the parsed XML JaSPer contest data
# into records of the contest database
# 'j' prefixes variables that contain JaSPer parsed data
# 'd' prefixes variables that reference the database madel
module Jasper
class JasperToDB
attr_reader :dContest

# accept parsed XML JaSPer contest data
# appropriately update or create records in the contest database
# return the id of the contest
def process_contest(jasper)
  jCID = jasper.contest_id
  dContest = nil
  contest_params = extract_contest_params_hash(jasper)
  if (jCID)
    dContest = updateOrCreateContest(jCID, contest_params)
  else
    dContest = Contest.create(contest_params)
  end
  if dContest
    process_scores(dContest, jasper)
  end
  dContest
end

###
private
###

def updateOrCreateContest(id, contest_params)
  begin
    dContest = Contest.find(id)
    logger.info "JasperToDB found contest #{dContest.name} for update"
    dContest.reset_to_base_attributes
    dContest.update(contest_params)
  rescue ActiveRecord::RecordNotFound
    dContest = Contest.create(contest_params)
  end
  dContest
end

def extract_contest_params_hash(jasper)
  contest_params = {};
  contest_params['name'] = jasper.contest_name.strip.slice(0,48)
  contest_params['start'] = jasper.contest_date
  contest_params['region'] = jasper.contest_region.strip.slice(0,16)
  contest_params['director'] = jasper.contest_director.strip.slice(0,48)
  contest_params['city'] = jasper.contest_city.strip.slice(0,24)
  contest_params['state'] = jasper.contest_state.strip.slice(0,2).upcase
  contest_params['chapter'] = jasper.contest_chapter
  contest_params
end

def process_scores(dContest, jasper)
  aircat = jasper.aircat
  jasper.categories_scored.each do |jCat|
    dCategory = category_for(jasper, aircat, jCat)
    logger.debug "JasperToDB processing category #{dCategory.name}"
    jasper.flights_scored(jCat).each do |jFlt|
      dFlight = flight_for(dContest, dCategory, jasper, jCat, jFlt)
      logger.debug "JasperToDB processing flight #{dFlight.displayName}"
      jasper.pilots_scored(jCat, jFlt).each do |jPilot|
        dPilot = pilot_for(jasper, jCat, jPilot)
        logger.debug "JasperToDB processing pilot #{dPilot.name}"
        dSequence = sequence_for(jasper, jCat, jFlt, jPilot)
        dPilotFlight = pilot_flight_for(dFlight, dPilot, dSequence, jasper, jCat, jFlt, jPilot)
        jasper.judge_teams(jCat, jFlt).each do |jJudgeTeam|
          dJudge = judge_for(jasper, jCat, jFlt, jJudgeTeam)
          dAssist = judge_assist_for(jasper, jCat, jFlt, jJudgeTeam)
          dJudgeTeam = judge_team_for(dJudge, dAssist)
          logger.debug "JasperToDB processing grades for #{dJudgeTeam.team_name}"
          process_grades(dJudgeTeam, dPilotFlight, dSequence, jasper, jCat, jFlt, jPilot, jJudgeTeam)
        end
      end
    end
  end
end

def category_for(jasper, aircat, jCat)
  category_name = jasper.category_name(jCat)
  cat = Category.find_for_cat_aircat(category_name, aircat)
  if !cat
    aircat_name = aircat == 'G' ? 'Glider' : 'Power'
    cat = Category.create(:sequence => jCat, :category => category_name,
      :aircat => aircat, :name => category_name + ' ' + aircat_name)
  end
  cat
end

def flight_for(dContest, dCategory, jasper, jCat, jFlt)
  chief = chief_for(jasper, jCat, jFlt)
  assist = chief_assist_for(jasper, jCat, jFlt)
  dContest.flights.create(
    :category_id => dCategory.id,
    :category => dCategory.category,
    :aircat => dCategory.aircat,
    :name => jasper.flight_name(jFlt),
    :sequence => jFlt,
    :chief_id => chief.id,
    :assist_id => assist.id)
end

def member_for(iac_id, given_name, family_name)
  if (0 < iac_id.to_i)
    Member.find_or_create_by_iac_number(iac_id, given_name, family_name)
  else
    Member.find_or_create_by_name(iac_id, given_name, family_name)
  end
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
    dJudgeTeam = Judge.create(:judge => dJudge, :assist => dAssist)
  end
  dJudgeTeam
end

def sequence_for(jasper, jCat, jFlt, jPilot)
  ks_string = jasper.k_values_for(jCat, jFlt, jPilot)
  ks = ks_string.split.map { |k_s| k_s.to_i }
  ks = ks.select { |k| k != 0 }
  Sequence.find_or_create(ks)
end

def pilot_flight_for(dFlight, dPilot, dSequence, jasper, jCat, jFlt, jPilot)
  PilotFlight.create(
    :flight_id => dFlight.id,
    :pilot_id => dPilot.id,
    :sequence_id => dSequence.id,
    :chapter => jasper.pilot_chapter(jCat, jPilot),
    :penalty_total => jasper.penalty(jCat, jFlt, jPilot))
end

def process_grades(dJudgeTeam, dPilotFlight, dSequence, jasper, jCat, jFlt, jPilot, jJudgeTeam)
  grades_string = jasper.grades_for(jCat, jFlt, jPilot, jJudgeTeam)
  # can get empty grades on non-scoring chief
  if !grades_string.empty?
    grades = grades_string.split
    grades = grades.map { |g| (g.to_f * 10.0).round }
    grades = remove_extraneous_grades(grades, dSequence.figure_count)
    dPilotFlight.scores.create(
      :judge_id => dJudgeTeam.id,
      :values => grades)
  end
end

def remove_extraneous_grades(grades, ctFigures)
  if 0 < ctFigures
    abbrev = grades[0, ctFigures - 1]
    abbrev << grades.last
  else
    grades
  end
end

end #class
end #module
