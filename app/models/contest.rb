class Contest < ApplicationRecord
  has_many :flights, :dependent => :destroy
  has_many :jc_results, :dependent => :destroy
  has_many :pc_results, :dependent => :destroy

  has_one :manny_synch, :dependent => :nullify
  has_many :data_posts, :dependent => :nullify
  has_many :failures, :dependent => :destroy

  validates :name, :length => { :in => 4..48 }
  validates :city, :length => { :maximum => 24 }
  validates :state, :length => { :maximum => 2 }
  validates :director, :length => { :maximum => 48 }
  validates :region, :length => { :maximum => 16 }
  validates_presence_of :start
  validate :busy_time_semantics

  def to_s
    "#{name} on #{start.strftime('%b %d, %Y')}"
  end

  def place
    "#{city}, #{state} (#{region})"
  end

  def year_name
    "#{start.year} #{sobriquet}"
  end

  def year
    start.year if start
  end

  def year=(yyyy)
    self.start = Time.mktime(yyyy)
  end

  def has_soft_zero
    2014 <= year
  end

  def sobriquet
    if name && !name.empty?
      name
    else
      id
    end
  end

  # remove all contest associated data except the base
  # attributes.  Keep association with manny_synch
  def reset_to_base_attributes
    flights.destroy_all
    pc_results.destroy_all
    jc_results.destroy_all
    failures.destroy_all
  end


  private

  def busy_time_semantics

    # If both times are blank, there's no need to validate further
    return if busy_start.blank? && busy_end.blank?

    # Complain if one time is blank and the other is present
    if busy_start.present? && busy_end.blank?
      errors.add(:busy_end, "must be present if busy_start is present")
    elsif busy_start.blank? && busy_end.present?
      errors.add(:busy_start, "must be present if busy_end is present")
    else
      # Complain if the times are out of order
      errors.add(:busy_end, "must be after busy_start") if busy_start >= busy_end
    end

  end

end
