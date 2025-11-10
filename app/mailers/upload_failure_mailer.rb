class UploadFailureMailer < ApplicationMailer

  include ApplicationHelper

  def notify
    @record = params[:record]
    mail to: email_for(:to), cc: email_for(:cc), subject: '[IACCDB] Batch job failed', record: @record
    Rails.logger.info '@@ Sent notification email re: batch job failure'
  end

end
