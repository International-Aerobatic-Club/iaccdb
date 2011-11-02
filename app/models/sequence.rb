class Sequence < ActiveRecord::Base
  has_many :pilot_flight

  # k_values is array of int figure k
  def self.find_or_create(k_values)
    attrs = create_attrs(k_values)
    sa = Sequence.where(attrs)
    if sa.empty?
      Sequence.new(attrs)
    else
      sa.first
    end
  end

  # k_values is array of int figure k
  # returns hash of attributes for sequence record
  def self.create_attrs(k_values)
    attrs = {}
    attrs[:figure_count] = k_values.size
    total_k = 0
    mod_3_total = 0
    k_values.each do |k|
      total_k += k
      mod_3_total += k % 3
    end
    attrs[:total_k] = total_k
    attrs[:mod_3_total] = mod_3_total
    attrs[:k_values] = k_values
    attrs
  end
end
