class PilotsController < ApplicationController
  def index
    @pilots = Member.find_by_sql("select 
      m.given_name, m.family_name, m.id
      from members m where m.id in (select distinct pilot_id from pilot_flights)
      order by  m.family_name, m.given_name")
  end

  def show
    id = params[:id]
    @pilot = Member.find(id)
    @contests = Contest.find_by_sql(["select distinct
      c.id, c.name, c.start, c.region, f.category
      from pilot_flights p, members m, flights f, contests c
      where p.pilot_id = :id and p.flight_id = f.id and f.contest_id = c.id
      order by c.start desc", {:id => id}])
  end
end
