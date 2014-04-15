class DataPost < ActiveRecord::Base
  belongs_to :contest

  def filename
    post_dir = "#{::Rails.root.to_s}/posts"
    if (!Dir.exist?(post_dir))
      Dir.mkdir(post_dir)
    end
    File.join(post_dir,"JaSPer_post_#{id}.xml")
  end

  def store(data)
    io = File.open(filename, 'w+')
    io.write(data)
    io.close
  end

  def data
    begin
      IO.read(filename)
    rescue Exception => ex
      ex.message
    end
  end

  def to_s
    "data post id #{id} for contest id #{contest_id}"
  end
end
