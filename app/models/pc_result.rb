class PcResult < ActiveRecord::Base
  belongs_to :pilot, :class_name => 'Member'
  belongs_to :contest
end
