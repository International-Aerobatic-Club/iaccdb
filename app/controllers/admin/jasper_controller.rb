require 'iac/jasper_parse'
require 'iac/jasper_to_db'
require 'libxml'

class Admin::JasperController < ApplicationController

def results
  respond_to do |format|
    format.xml {
      begin
        jasper = JaSPer::JaSPerParse.new
        j2d = IAC::JaSPerToDB.new
        parser = LibXML::XML::Parser.io(request.body)
        jasper.do_parse(parser)
        contest = j2d.process_contest(jasper)
        @contestID = contest.id
      rescue Exception => ex
        @exception = ex
        render :exception, :status => 400
      end
    }
  end
end

end
