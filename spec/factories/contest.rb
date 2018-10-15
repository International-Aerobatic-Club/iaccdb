module ContestFactory
  def contest_name
    [
      Faker::Superhero.descriptor,
      'Aerobatic',
      Faker::LeagueOfLegends.summoner_spell
    ].join(' ')
  end

  def region_name
    %w[
      SouthEast SouthWest MidAmerica SouthCentral Northeast Southeast
    ].sample
  end

  def chapter_number
    %w[52 35 38 58 19 1 12].sample
  end
end
