class FurtherController < ApplicationController

  def participation
    judge_counts = JyResult.joins(:category).select(
        'count(distinct(judge_id)) as count, categories.id as category_id, year'
      ).group(:category_id, :year)
    @cat_year_judge_count = judge_counts.group_by { |count| count.category_id }
    @cat_year_judge_count.each do |key, ac| 
      @cat_year_judge_count[key] = ac.group_by { |count| count.year }
    end
    yy = judge_counts.collect { |jy_result| jy_result.year }
    @years = Set.new(yy)
    judge_counts = JyResult.select('count(distinct(judge_id)) as count, year').group(:year)
    @cat_year_judge_count['any'] = judge_counts.group_by { |count| count.year }

    pilot_counts = PilotFlight.joins(:flight => [:categories, :contest]).select(
      'count(distinct(`pilot_flights`.`pilot_id`)) as count,
       categories.id as category_id,
       year(`contests`.`start`) as year'
    ).group(:category_id, :year)
    @cat_year_pilot_count = pilot_counts.group_by { |pf| pf.category_id }
    @cat_year_pilot_count.each do |key, apcr| 
      @cat_year_pilot_count[key] = apcr.group_by { |pcr| pcr.year }
    end
    yy = pilot_counts.collect { |pf| pf.year }
    @years.merge(yy)
    pilot_counts = PilotFlight.joins(:flight => :contest).select(
      'count(distinct(`pilot_flights`.`pilot_id`)) as count, 
       year(`contests`.`start`) as year').group(:year)
    @cat_year_pilot_count['any'] = pilot_counts.group_by { |count| count.year }

    @categories = Category.order(:sequence)
  end

  def airplane_make_model
    @years = Contest.joins(:flights => {:pilot_flights => :airplane}).select(
      "distinct year(start) as anum"
      ).order('anum desc'
      ).all.collect { |contest| contest.anum }
    @year = params[:year] || @years.first
    airplanes_with_cat = Airplane.joins([
      {:pilot_flights => {:flight => [:categories, :contest]}},
      :make_model
      ]).select(
        'count(pilot_flights.id) as flight_count',
        'make_models.make',
        'make_models.model',
        'categories.name as category'
      ).where(['year(contests.start) = ?', @year]
      ).group('make_models.make, make_models.model, categories.id')
   @airplanes = airplanes_with_cat.inject({}) do |m,a| 
     m[a.category] ||= []
     m[a.category] << a
     m
   end
  end
end
