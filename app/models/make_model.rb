class MakeModel < ApplicationRecord
  has_many :airplanes, :dependent => :nullify

  # The database has:
  #   t.index ["make", "model"], name: "...", unique: true
  # We rely on the unique index in place of the Rails validation.
  # A save or update will throw
  #   ActiveRecord::StatementInvalid when a make model collision occurs
  # validates_uniqueness_of :model, :scope => :make

  def self.all_by_make
    MakeModel.order(:make, :model).all.to_a.group_by(&:make)
  end
end
