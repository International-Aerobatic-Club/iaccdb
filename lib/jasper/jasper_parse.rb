module Jasper
class JasperParse
  attr_reader :document

  def do_parse(parser)
    @document = parser.parse
  end

  def contest_id
    nodes = @document.find_first('/ContestResults/ContestInfo/cdbId')
    nodes ||= @document.find_first('/ContestResults/ContestInfo/cdbID')
    cid = nodes ? nodes.inner_xml : nil
    cid = cid.to_i if cid
  end

  def contest_name
    nodes = @document.find('/ContestResults/ContestInfo/Contest')
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def contest_date
    nodes = @document.find('/ContestResults/ContestInfo/Date')
    text = nodes && nodes.first ? nodes.first.inner_xml : nil
    if text
      Date.strptime(text, '%m/%d/%y')
    else
      nil
    end
  end

  def contest_region
    nodes = @document.find('/ContestResults/ContestInfo/Region')
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def contest_director
    nodes = @document.find('/ContestResults/ContestInfo/Director')
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def contest_city
    nodes = @document.find('/ContestResults/ContestInfo/City')
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def contest_state
    nodes = @document.find('/ContestResults/ContestInfo/State')
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  def contest_chapter
    nodes = @document.find('/ContestResults/ContestInfo/HostChapter')
    clean_chapter(nodes && nodes.first ? nodes.first.inner_xml : '')
  end

  def aircat
    nodes = @document.find('/ContestResults/ContestInfo/Type')
    type = nodes && nodes.first ? nodes.first.inner_xml : 'Powered'
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
      ids << node.value if node.node_type == XML::Node::ATTRIBUTE_NODE
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
    name.strip
  end

  def pilot_raw_last_name(jCat, jPilot)
    nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/Name/Last")
    nodes && nodes.first ? nodes.first.inner_xml : ''
  end

  PATCH_REGEX = /\(patch\)/i

  def pilot_last_name(jCat, jPilot)
    pilot_raw_last_name(jCat, jPilot).gsub(PATCH_REGEX,'').strip
  end

  def pilot_is_hc(jCat, jPilot)
    name = pilot_raw_last_name(jCat, jPilot)
    match = PATCH_REGEX.match(name)
    match != nil
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
    if (jCat == 1) # primary has no free
      jFlt = 1
    end
    if (jCat == 2)  # sportsman has no unknown
      jFlt = 2 if 2 < jFlt
    end
    case jFlt
    when 2 # free
      nodes = @document.find("/ContestResults/Pilots/Category[@CategoryID=#{jCat}]/Pilot[@PilotID=#{jPilot}]/FreestyleKs")
      if (nodes.length == 0)
        nodes = @document.find("/ContestResults/KnownKFactors/Category[@CategoryID=#{jCat}]")
      end
    when 3 # unknown
      nodes = @document.find("/ContestResults/UnKnownKFactors/One/Category[@CategoryID=#{jCat}]")
    when 4 # unknown II
      nodes = @document.find("/ContestResults/UnKnownKFactors/Two/Category[@CategoryID=#{jCat}]")
    else # known
      nodes = @document.find("/ContestResults/KnownKFactors/Category[@CategoryID=#{jCat}]")
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

end #class
end #module
