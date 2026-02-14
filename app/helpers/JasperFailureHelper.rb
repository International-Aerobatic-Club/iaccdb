module JasperFailureHelper

  def notify_admin_of_failure(record = nil)
    UploadFailureMailer.with(record: record).notify.deliver_later
  end

end
