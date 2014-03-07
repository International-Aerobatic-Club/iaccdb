require 'libxml'

class Admin::JasperController < ApplicationController

def results
  xml_data = params[:contest_xml]
  jasper = Jasper::JasperParse.new
  if xml_data.respond_to? :read
    begin
      logger.info "JasperController: parse xml file"
      parser = LibXML::XML::Parser.io(xml_data)
      jasper.do_parse(parser)
    rescue Exception => ex
      logger.error ex.inspect
      logger.error ex.backtrace.join('\n')
      @exception = ex.message
      render :exception, :status => 400
    end
  elsif xml_data.is_a?(String)
    begin
      logger.info "JasperController: parse xml param"
      parser = LibXML::XML::Parser.string(xml_data)
      jasper.do_parse(parser)
    rescue Exception => ex
      logger.error ex.inspect
      logger.error ex.backtrace.join('\n')
      @exception = ex.message
      render :exception, :status => 400
    end
  else
    @exception = "invalid post"
    render :exception, :status => 400
  end
  begin
    logger.info "JasperController: process xml to database"
    j2d = Jasper::JasperToDB.new
    contest = j2d.process_contest(jasper)
    if (contest.save)
      @contestID = contest.id
      render :results
    else
      @exception = "failed to save"
      render :exception, :status => 500
    end
  rescue Exception => ex
    logger.error ex.inspect
    logger.error ex.backtrace.join('\n')
    @exception = ex.message
    render :exception, :status => 500
  end
end

end
