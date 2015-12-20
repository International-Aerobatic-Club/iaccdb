# find contests in 2014, 2015 that flew the four minute program
# retrieve the latest data post from that contest
# process the four minute free data only
# recompute that flight
# after all done, recompute the roll-ups
# use rails runner cmd/reprocess_four_minute.rb

require 'libxml'

class ReprocessFourMinute
  def initialize(c, p)
    @contest = c
    @post = p
  end

  def reprocess
    jasper = read_post
    process_scores(jasper)
  end

  def read_post
    parser = LibXML::XML::Parser.file(@post.filename)
    jasper = Jasper::JasperParse.new
    jasper.do_parse(parser)
    jasper
  end

  def process_scores(jasper)
    j2db = Jasper::JasperToDB.new
    j2db.d_contest = @contest
    computer = ContestComputer.new(@contest)
    four_minute = Category.where(category: 'four minute').first
    aircat = jasper.aircat
    jasper.categories_scored.each do |jCat|
      dCategory = j2db.category_for(jasper, aircat, jCat)
      if dCategory == four_minute
        puts "Processing four minute data."
        j2db.process_category(jasper, dCategory, jCat)
        fm_flights = @contest.flights.where(
          category: four_minute).order('created_at desc')
        latest = true
        dFlight = nil
        fm_flights.find_each do |flight|
          # it makes sense to delete the old flight data after
          # writing the new flight data, because some of the old
          # data associations will be used by the new data
          if latest
            dFlight = flight
          else
            flight.destroy
          end
          latest = false
        end
        if dFlight == nil
          puts "Missing flight for processed four minute data"
        else
          computer.compute_flight_results(dFlight)
          computer.compute_flight_judge_metrics(dFlight)
          dFlight.save
          @contest.save
        end
      end
    end
  end
end

pcs = []
contests = Contest.joins(:flights => :category).where(
  "categories.category = 'four minute' and 2014 <= year(contests.start)")
contests.all.each do |c|
  begin
    post = c.data_posts.where(
        has_error: false, is_obsolete: false
      ).order('created_at desc').first
    if (post == nil)
      puts "No valid data post for #{c}"
      pcs << c
    else
      puts "Processing #{post} #{c}"
      rfm = ReprocessFourMinute.new(c, post)
      rfm.reprocess
    end
  rescue Exception => e
    puts "\nSomething went wrong with contest #{c}"
    puts e.message
    e.backtrace.each { |l| puts l }
    pcs << c
  end
  puts "Process the judge rollups"
end
IAC::JudgeRollups.compute_jy_results(2014)
IAC::JudgeRollups.compute_jy_results(2015)
unless pcs.empty?
  puts "There were problems with these:"
  pcs.each { |contest| puts contest }
end


