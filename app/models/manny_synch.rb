class MannySynch < ActiveRecord::Base
  attr_protected :id

  belongs_to :contest

  # pass an IAC::Contest
  # returns an array containing MannySynch and string action:
  #   skip, update, or create
  def self.contest_action(contest)
    logger.debug("manny record date #{contest.manny_date}")
    ms = MannySynch.where(:manny_number => contest.mannyID).first
    if ms
      logger.debug("date in database #{ms.synch_date}");
      if ms.synch_date >= contest.manny_date
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
