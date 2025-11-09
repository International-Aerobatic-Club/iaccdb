
require 'libxml'

class Admin::JasperController < ApplicationController

  skip_before_action :verify_authenticity_token

  class EmptyDataException < Exception
  end

  def results

    @exception = nil
    status = 200
    post_record = DataPost.create

    begin

      xml_data = params[:contest_xml]

      if xml_data && xml_data.is_a?(String)
        raise EmptyDataException if xml_data.empty?
        logger.info "JasperController: parse xml param"
        post_record.store(xml_data)
      elsif xml_data
        logger.info "JasperController: read xml file"
        post_record.store(xml_data.read)
      else
        raise EmptyDataException
      end

      parser = LibXML::XML::Parser.string(post_record.data)
      jasper = Jasper::JasperParse.new
      jasper.do_parse(parser)
      @contest_id = jasper.contest_id

      if (@contest_id == nil || @contest_id <= 0)
        j2d = Jasper::JasperToDB.new
        contest = Contest.create! j2d.extract_contest_params_hash(jasper)
        @contest_id = contest.id
      end

      post_record.contest_id = @contest_id

    rescue EmptyDataException
      @exception = "no contest data provided"
      post_record.store('<ContestResults/>')
      status = 400
      post_record.has_error = true
      post_record.error_description = @exception

    rescue StandardError => ex
      @exception = ex.message
      status = 500
      logger.error ex.inspect
      logger.error ex.backtrace.join("\n")
      post_record.has_error = true
      post_record.error_description = @exception

    ensure
      post_record.save!
    end

    self.formats = [:xml]

    if status == 200
      Delayed::Job.enqueue Jobs::ProcessJasperJob.new(post_record.id)
      render :results
    else
      render :exception, :status => status
    end

  end

end
