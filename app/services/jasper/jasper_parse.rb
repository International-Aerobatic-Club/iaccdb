require 'libxml'

module Jasper
class JasperParse
  attr_reader :document

  def do_parse(parser)
    LibXML::XML::Error.set_handler(&LibXML::XML::Error::QUIET_HANDLER)
    @document = parser.parse
  end

  def contest_id
    nodes = @document.find_first('/ContestResults/ContestInfo/cdbId')
    nodes ||= @document.find_first('/ContestResults/ContestInfo/cdbID')
    cid = nodes ? nodes.inner_xml : nil
    cid = cid.to_i if cid
  end

  def contest_name
    clean_text(@document.find('/ContestResults/ContestInfo/Contest'))
  end

  def contest_date
    nodes = @document.find('/ContestResults/ContestInfo/Date')
    text = nodes && nodes.first ? nodes.first.inner_xml : nil
    start = nil
    if text
      begin
        start = Date.strptime(text, '%m/%d/%y')
      rescue ArgumentError
        begin
          start = Date.strptime(text, '%Y-%m-%d')
        rescue ArgumentError
          start = nil
        end
      end
    end
    start
  end

  def contest_region
    clean_text(@document.find('/ContestResults/ContestInfo/Region'))
  end

  def contest_director
    clean_text(@document.find('/ContestResults/ContestInfo/Director'))
  end

  def contest_city
    clean_text(@document.find('/ContestResults/ContestInfo/City'))
  end

  def contest_state
    clean_text(@document.find('/ContestResults/ContestInfo/State'))
  end

  def contest_chapter
    nodes = @document.find('/ContestResults/ContestInfo/HostChapter')
    clean_chapter(nodes && nodes.first ? nodes.first.inner_xml : '')
  end

  def aircat
    type = clean_text(@document.find('/ContestResults/ContestInfo/Type'))
    type = 'Powered' if type.empty?
    type[0,1]
  end

  CATEGORY_NAMES = ['Primary', 'Sportsman',
    'Intermediate', 'Advanced', 'Unlimited', 
    'Four Minute']
  def category_name(jCat)
    CATEGORY_NAMES[jCat-1]
  end

  def categories_scored
    catIDList = []
    nodes = @document.find('/ContestResults/Scores/Category')
    nodes.each do |node|
      attribs = node.attributes
      attr = attribs.get_attribute('CategoryID')
      if attr
        catIDList << attr.value.to_i
      end
    end
    catIDList
  end

  FLIGHT_NAMES = ['Known', 'Free', 'Unknown', 'Unknown II']
  def flight_name(jFlt)
    FLIGHT_NAMES[jFlt-1]
  end

  def flights_scored(jCat)
    fltIDList = []
    nodes = @document.find("/ContestResults/Scores/Category[@CategoryID=#{jCat}]/Flight")
    nodes.each do |node|
      attribs = node.attributes
      attr = attribs.get_attribute('FlightID')
      if attr
        fltIDList << attr.value.to_i
      end
    end
    fltIDList
  end

  def pilots_scored(jCat, jFlt)
    pIDList = []
    nodes = @document.find("/ContestResults/Scores/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Pilot")
    nodes.each do |node|
      attribs = node.attributes
      attr = attribs.get_attribute('PilotID')
      if attr
        pIDList << attr.value.to_i
      end
    end
    pIDList
  end

  def judge_teams(jCat, jFlt)
    jtList = []
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge")
    nodes.each do |node|
      attribs = node.attributes
      attr = attribs.get_attribute('JudgeID')
      if attr
        jtList << attr.value.to_i
      end
    end
    jtList
  end

  def collegiate_pilots(jCat)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[contains(./SubCategory/text(), 'CollegiateSeries')]/@PilotID")
    ids = []
    nodes.each do |node|
      ids << node.value if node.node_type == LibXML::XML::Node::ATTRIBUTE_NODE
    end
    ids
  end

  def chief_iac_number(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/IACNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def chief_first_name(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/Name/First")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def chief_last_name(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/Name/Last")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def chief_assist_iac_number(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/Assistant[1]/IACNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def chief_assist_first_name(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/Assistant[1]/Name/First")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def chief_assist_last_name(jCat, jFlt)
    nodes = @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=0]/Assistant[1]/Name/Last")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def pilot_iac_number(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/IACNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def pilot_first_name(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Name/First")
    name = nodes && nodes.first ? nodes.first.inner_xml : ''
    (name.nil?) ? '' : name.strip
  end

  def pilot_raw_last_name(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Name/Last")
    name = nodes && nodes.first ? nodes.first.inner_xml : ''
    (name.nil?) ? '' : name
  end

  def pilot_subcategories(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/SubCategory")
    subcats = nodes && nodes.first ? nodes.first.inner_xml : ''
    subcats || ''
  end

  PATCH_REGEX = /\(patch\)/i

  def pilot_last_name(jCat, jPilot)
    pilot_raw_last_name(jCat, jPilot).gsub(PATCH_REGEX,'').strip
  end

  def pilot_is_hc(jCat, jPilot)
    PATCH_REGEX.match(pilot_raw_last_name(jCat, jPilot)) != nil ||
      /HorsConcours/.match(pilot_subcategories(jCat, jPilot)) != nil
  end

  def pilot_chapter(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Chapter")
    chapter = (nodes && nodes.first ? nodes.first.inner_xml : '') || ''
    chapter = chapter.gsub(/[^0-9]/, ' ')
    chapter = chapter.split(/ +/)
    chapter = chapter.select { |c| c != nil && !c.empty? }
    chapter.join('/')[0,8]
  end

  # this one returns nil, not the empty string, if no college
  def pilot_college(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/College")
    nodes && nodes.first ? nodes.first.inner_xml : nil
  end

  def airplane_make(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Aircraft/Make")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def airplane_model(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Aircraft/Model")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def airplane_reg(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Aircraft/NNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def penalty(jCat, jFlt, jPilot)
    nodes =
    @document.find("/ContestResults/Scores/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Pilot[@PilotID=#{jPilot}]/Penalty")
    if nodes && nodes.first
      penalty_text = nodes.first.inner_xml
      penalty_text.to_i
    else
      0
    end
  end

  def judge_iac_number(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/IACNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def judge_first_name(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/Name/First")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def judge_last_name(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/Name/Last")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def judge_assist_iac_number(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/Assistant/IACNumber")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def judge_assist_first_name(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/Assistant/Name/First")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def judge_assist_last_name(jCat, jFlt, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Judges/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Judge[@JudgeID=#{jJudgeTeam}]/Assistant/Name/Last")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def grades_for(jCat, jFlt, jPilot, jJudgeTeam)
    nodes =
    @document.find("/ContestResults/Scores/Category[@CategoryID=#{jCat}]/Flight[@FlightID=#{jFlt}]/Pilot[@PilotID=#{jPilot}]/Judge[@JudgeID=#{jJudgeTeam}]/Figures")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def k_values_for(jCat, jFlt, jPilot)
    if(jCat == 1 || jFlt == 1)
      # Known or Primary
      nodes = @document.find(
        "/ContestResults/KnownKFactors/Category[@CategoryID=#{jCat}]")
    elsif(jCat == 2 || jFlt == 2)
      # Sportsman or Free
      # look for freestyle K's associated with the category, pilot, flight
      nodes = @document.find(
        "/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/" +
        "Pilot[@PilotID=#{jPilot}]/FreestyleKs[@FlightID=#{jFlt}]")
      if (jCat == 2 && nodes.length == 0)
        # look for sportsman freestyle K's associated with pilot, flight 2
        nodes = @document.find(
          "/ContestResults/Pilots/Category[@CategoryID=2]/" +
          "Pilot[@PilotID=#{jPilot}]/FreestyleKs[@FlightID=2]")
      end
      if (nodes.length == 0)
        # fall back to freestyle K's associated with pilot, no flight identified
        nodes = @document.find(
          "/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/" +
          "Pilot[@PilotID=#{jPilot}]/FreestyleKs")
      end
      if (nodes.length == 0)
        # fall back to known sequence values
        nodes = @document.find(
          "/ContestResults/KnownKFactors/Category[@CategoryID=#{jCat}]")
      end
    else
      # look for unknown K's associated with the category, pilot, flight
      nodes = @document.find(
        "/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/" +
        "Pilot[@PilotID=#{jPilot}]/FreestyleKs[@FlightID=#{jFlt}]")
      if (nodes.length == 0)
        # look for unknown K's associated with the category, flight
        kpath = case jFlt
          when 3 # unknown 1
            'UnKnownKFactors/One'
          when 4 # unknown 2
            'UnKnownKFactors/Two'
          else # known or free
            'KnownKFactors'
          end
        nodes = @document.find(
          "/ContestResults/#{kpath}/Category[@CategoryID=#{jCat}]")
      end
    end
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def clean_chapter(chapter)
    if (chapter)
      chapter = chapter.gsub(/[^0-9]/,' ')
      chapter.to_i
    else
      ''
    end
  end

  def clean_text(nodes)
    text = nodes && nodes.first ? nodes.first.inner_xml : nil
    text.nil? ? '' : text
  end

end #class
end #module
