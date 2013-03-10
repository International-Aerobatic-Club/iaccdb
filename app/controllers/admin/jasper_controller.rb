require 'libxml'

class Admin::JasperController < ApplicationController

def results
  xml_data = params[:contest_xml]
  if xml_data.respond_to? :read
    begin
      jasper = Jasper::JasperParse.new
      j2d = Jasper::JasperToDB.new
      parser = LibXML::XML::Parser.io(xml_data)
      jasper.do_parse(parser)
      contest = j2d.process_contest(jasper)
      @contestID = contest.id
    rescue Exception => ex
      @exception = ex
      render :exception, :status => 400
    end
  end
end

end
