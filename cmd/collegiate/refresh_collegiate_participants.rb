# read data posts and refresh the collegiate competitors and teams
# for a given year
# use rails runner cmd/collegiate/refresh_collegiate_participants.rb
require 'xml'

class RefreshCollegiateParticipants

  attr_accessor :year, :pilots, :colleges

  def initialize(year)
    @year = year
    @colleges = {} # index by name
    @pilots = {} # index by iac_id
  end

  def pilot_for(iac_id, first_name, last_name)
    if iac_id && first_name && last_name
      iac_id = iac_id.strip
      first_name = first_name.strip
      last_name = last_name.strip
      pilot = pilots[iac_id]
      unless pilot
        pilot = Member.find_or_create_by_iac_number(iac_id, first_name, last_name)
        pilots[iac_id] = pilot
      end
      pilot
    end
  end

  def college_for(name)
    if name
      name = name.strip
      college = colleges[name]
      unless college
        college = CollegiateResult.find_or_create_team_for_year(name, year)
        colleges[name] = college
      end
      college
    end
  end

  def add_pilot_college(pilot, college)
    puts "#{pilot} into #{college}"
    college.add_member_if_not_present(pilot)
    college.save
  end

  def process_post(post)
    jasper = Jasper::JasperParse.new
    parser = XML::Parser.file(post.filename)
    jasper.do_parse(parser)
    categories = jasper.categories_scored
    categories.each do |icat|
      collegiate_pilots = jasper.collegiate_pilots(icat)
      collegiate_pilots.each do |jpilot|
        pilot = pilot_for(
          jasper.pilot_iac_number(icat, jpilot),
          jasper.pilot_first_name(icat, jpilot),
          jasper.pilot_last_name(icat, jpilot)
        )
        college = college_for(jasper.pilot_college(icat, jpilot))
        if college && pilot
          add_pilot_college(pilot, college)
        end
      end
    end
  end

  def print_results
    puts "Colleges"
    @colleges.each do |name, c| 
      puts "\t#{c}"
      c.members.each { |pilot| puts "\t\t#{pilot}" }
    end
    puts "\nPilots"
    @pilots.each do |iac_id, p|
      puts "\t#{p}"
      teams = Result.joins(:result_members).includes(:result_members).
        where(:result_members => { :member_id => p.id }, :year => year)
      teams.each { |team| puts "\t\t#{team}" }
    end
  end

  def process_data_posts
    posts = DataPost.where(['year(created_at) = ? and is_obsolete = false', 
      @year]).order('created_at')
    pcs = []
    posts.each do |post|
      begin
        if (post.has_error)
          puts "Skipping post #{post} has error, #{post.error_description}"
        elsif (post.is_obsolete)
          puts "Skipping post #{post} is obsolete"
        else
          puts "Processing #{post}"
          process_post post
        end
      rescue Exception => e
        puts "\nSomething went wrong with #{post}:"
        puts e.message
        e.backtrace.each { |l| puts l }
        pcs << post
      end
    end
    unless pcs.empty?
      puts "There were problems with these:"
      pcs.each { |post| puts post }
    end
    print_results
  end
end

year = ARGV.empty? ? 0 : ARGV[0].to_i
unless year && year != 0
  puts "Specify the year will refresh collegiate participants"
  puts "from JaSPer posts for that year.  Never deletes."
  exit 1
end
rcp = RefreshCollegiateParticipants.new(year)
rcp.process_data_posts

