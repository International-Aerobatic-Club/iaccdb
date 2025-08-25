class Failure < ApplicationRecord
  belongs_to :contest, optional: true
  belongs_to :data_post, optional: true

  before_validation :normalize_fields

  def normalize_fields
    if step != nil
      self.step = step.strip.slice(0,16)
    else
      self.step = ''
    end
  end
end
