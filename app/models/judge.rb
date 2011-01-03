class Judge < ActiveRecord::Base
  belongs_to :judge, :class_name => 'Member'
  belongs_to :assist, :class_name => 'Member'
end
