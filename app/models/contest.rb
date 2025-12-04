class Contest < ApplicationRecord
  has_many :flights, dependent: :destroy
  has_many :jc_results, dependent: :destroy
  has_many :pc_results, dependent: :destroy

  has_many :data_posts, dependent: :nullify
  has_many :failures, dependent: :destroy

  validates :name, length: { minimum: 4 }
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :director
  validates_presence_of :region
  validates_presence_of :start
  validate :unique_name_per_year

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

  # remove all contest associated data except the base attributes
  def reset_to_base_attributes
    flights.destroy_all
    pc_results.destroy_all
    jc_results.destroy_all
    failures.destroy_all
  end

  private

  def unique_name_per_year
    if Contest.where(name: name).where('YEAR(start) = ?', start&.year).where.not(id: id).present?
      errors.add(:name, "must be unique for a given year")
    end
  end

end
