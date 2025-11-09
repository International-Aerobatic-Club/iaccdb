class MakeModel < ApplicationRecord
  has_many :airplanes, dependent: :nullify

  # The database has:
  #   t.index ["make", "model"], name: "...", unique: true
  # We rely on the unique index in place of the Rails validation.
  # A save or update will throw
  #   ActiveRecord::StatementInvalid when a make model collision occurs
  # validates_uniqueness_of :model, :scope => :make

  def self.all_by_make(only_curated = false)
    query = MakeModel.order(:make, :model)
    query = query.where(curated: true) if only_curated
    query.all.to_a.group_by(&:make)
  end

  # split combined make and model into separate make and model
  # returns array [make, model]
  def self.split_make_model(make_model)
    make = model = nil
    if make_model
      amm = make_model.split(' ')
      if (1 < amm.length)
        model = amm.slice(1,make_model.length-1).join(' ')
        make = amm[0]
      else
        model = amm[0]
      end
    end
    [make, model]
  end

  def self.find_or_create_make_model(make, model)
    make = make ? make.strip : ''
    model = model ? model.strip : ''
    mm = nil
    begin
      MakeModel.transaction(requires_new: true) do
        mm = MakeModel.find_or_create_by(make: make, model: model)
      end
    rescue ActiveRecord::RecordNotUnique
      retry
    end
    mm
  end

  # Attempt to find a matching MakeModel record given single string
  #   that has concatenated make and model.
  # Use case insensitive match with spaces and hyphens removed.
  # Use the record with the longest matching make and model
  # Look for make matching the start and model matching the end.
  # Failing that, look for both make and model anywhere in the string.
  # Failing that, split the string and create a MakeModel record
  #   with the split make and model
  # Given that the number of records in the MakeModel table is relatively
  #   small, it seems worth the effort of so many queries
  def self.find_or_create_makemodel(make_model)
    match_string = make_model.downcase.gsub(/\s|-/, '')

    # try ordered match
    query = <<~SQL.gsub("\n", ' ')
      :ms like
        concat(lower(replace(replace(make, ' ', ''), '-', '')), '%')
      and
      :ms like
        concat('%', lower(replace(replace(model, ' ', ''), '-', '')))
      SQL
    mm = MakeModel.where(
      [query, { ms: match_string }]
    ).order('length(`model`), length(`make`)').limit(1).first

    # try both anywhere in string
    unless mm
      query = <<~SQL.gsub("\n", ' ')
        :ms like
          concat('%', lower(replace(replace(make, ' ', ''), '-', '')), '%')
        and
        :ms like
          concat('%', lower(replace(replace(model, ' ', ''), '-', '')), '%')
        SQL
      mm = MakeModel.where(
        [query, { ms: match_string }]
      ).order('length(`model`), length(`make`)').limit(1).first
    end

    unless mm
      mnm = split_make_model(make_model)
      mm = find_or_create_make_model(mnm[0], mnm[1])
    end
    mm
  end
end
