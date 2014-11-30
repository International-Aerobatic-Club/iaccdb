class DataPost < ActiveRecord::Base
  attr_accessible :step, :is_integrated, :has_error, :error_description, :is_obsolete

  belongs_to :contest

  def self.post_dir
    File.join(::Rails.root.to_s, 'posts')
  end

  def filename
    post_dir = DataPost.post_dir
    if (!Dir.exist?(post_dir))
      Dir.mkdir(spost_dir)
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
