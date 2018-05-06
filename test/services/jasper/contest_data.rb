require 'libxml'

module ContestData
  def parse_contest_data(data)
    parser = LibXML::XML::Parser.string(data)
    jasper = Jasper::JasperParse.new
    jasper.do_parse(parser)
    jasper
  end

  def blank_empty_contest(params = {})
    return <<~EXML
      <?xml version="1.0"?>
      <ContestResults>
        <Version>
           <XMLFormat>1.0</XMLFormat>
           <JaSPer>3.2.31</JaSPer>
           <Generated>Sat May 05 14:15:50 PDT 2018</Generated>
        </Version>
        <ContestInfo>
          <Id>#{params.fetch(:id,'')}</Id>
          <cdbId>#{params.fetch(:cbd_id,'')}</cdbId>
          <Contest>#{params.fetch(:name,'')}</Contest>
          <City>#{params.fetch(:city,'')}</City>
          <State>#{params.fetch(:state,'')}</State>
          <Date>#{params.fetch(:start,'')}</Date>
          <Director>#{params.fetch(:director,'')}</Director>
          <HostChapter>#{params.fetch(:chapter,'')}</HostChapter>
          <Region>#{params.fetch(:region,'')}</Region>
          <Type>#{params.fetch(:type,'')}</Type>
          <Comment>#{params.fetch(:comment,'')}</Comment>
        </ContestInfo>
      </ContestResults>
    EXML
  end
end
