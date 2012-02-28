class JyResult < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :category

  include JudgeMetrics
  
  def to_s
    "jy_result #{year} #{category.name} #{judge.name} Np:#{pilot_count} Rho: #{cc} Gamma: #{gamma} avgK: #{avgK}"
  end
end
