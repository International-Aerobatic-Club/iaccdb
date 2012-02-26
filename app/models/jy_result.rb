class JyResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :category

  include JudgeMetrics
  
  after_initialize do |jy_result|
    jy_result.zero_reset
  end
end
