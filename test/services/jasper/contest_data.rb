require 'libxml'

module ContestData
  def jasper_from_parser(parser)
    jasper = Jasper::JasperParse.new
    jasper.do_parse(parser)
    jasper
  end

  def parse_contest_data(data)
    jasper_from_parser(LibXML::XML::Parser.string(data))
  end

  # provide only the file name and place the file in SAMPLE_FILE_DIR
  SAMPLE_FILE_DIR = 'spec/fixtures/jasper'
  def jasper_parse_from_test_data_file(filename)
    testFile = File.join(SAMPLE_FILE_DIR, filename)
    jasper_from_parser(LibXML::XML::Parser.file(testFile))
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
