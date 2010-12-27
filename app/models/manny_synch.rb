class MannySynch < ActiveRecord::Base
  belongs_to :contest

  # pass an IAC::Contest
  # returns an array containing MannySynch and string action:
  #   skip, update, or create
  def self.contest_action(contest)
    ms = MannySynch.where(:manny_number => contest.mannyID).first
    if ms
      if ms.synch_date >= contest.manny_date
        # date in database (ms.synch_date) same or after manny record
        [ms, 'skip']
      else
        [ms, 'update']
      end
    else
      ms = MannySynch.new
      ms.manny_number = contest.mannyID
      [ms, 'create']
    end
  end

end
