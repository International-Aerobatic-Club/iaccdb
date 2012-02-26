class JudgesController < ApplicationController
  def index
    @judges = Member.find_by_sql("select 
      m.given_name, m.family_name, m.id
      from members m where m.id in (select distinct judge_id from judges)
      order by  m.family_name, m.given_name")
  end

  def show
    id = params[:id]
    @judge = Member.find(id)
    @jy_results = JyResult.includes(:category).order(
       "year DESC").find_all_by_judge_id(id)
    @jc_results = JcResult.includes(:c_result).find_all_by_judge_id(id)
    @contests = Contest.find_by_sql(["select distinct
      c.id, c.name, c.start, c.region, f.category
      from pilot_flights p, judges j, scores s, flights f, contests c
      where j.judge_id = :id and s.judge_id = j.id and 
        s.pilot_flight_id = p.id and p.flight_id = f.id and f.contest_id = c.id
      order by c.start desc, f.sequence", {:id => id}])
  end
end
