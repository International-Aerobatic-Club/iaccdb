class JyResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :category

  include JudgeMetrics
  
end
