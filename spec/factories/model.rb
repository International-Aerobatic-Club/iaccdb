include ContestFactory
FactoryBot.define do
### Airplane
  factory :airplane do |r|
    make { Faker::Company.name }
    model { Faker::Company.unique.name }
    reg do
      Faker::Number.between(from: 100, to: 999).to_s +
      Faker::Name.initials(2)
    end
    make_model
  end
### MakeModel
  factory :make_model do
    make { Faker::Space.nasa_space_craft }
    model { Faker::Space.unique.meteorite }
    empty_weight_lbs { Faker::Number.between(from: 600, to: 1600) }
    max_weight_lbs { Faker::Number.between(from: 300, to: 800) + empty_weight_lbs }
    horsepower { Faker::Number.between(from: 40, to: 600) }
    seats { Faker::Number.between(from: 1, to: 4) }
    wings { Faker::Number.between(from: 1, to:2) }
  end
### Member
  factory :member do |r|
    r.sequence(:iac_id) { |i| 10 ** Faker::Number.between(from: 2, to: 6) + i }
    family_name { Faker::Name.last_name }
    given_name { Faker::Name.first_name }
  end
  factory :tom_adams, :class => Member do |r|
    r.iac_id { 1999 }
    r.family_name { 'Adams' }
    r.given_name { 'Tom' }
  end
  factory :bill_denton, :class => Member do |r|
    r.iac_id { 9821 }
    r.family_name { 'Denton' }
    r.given_name { 'Bill' }
  end
  factory :lynne_stoltenberg, :class => Member do |r|
    r.iac_id { 431354 }
    r.family_name { 'Stoltenberg' }
    r.given_name { 'Lynne' }
  end
  factory :jim_wells, :class => Member do |r|
    r.iac_id { 20352 }
    r.family_name { 'Wells' }
    r.given_name { 'Jim' }
  end
  factory :klein_gilhousen, :class => Member do |r|
    r.iac_id { 21489 }
    r.family_name { 'Gilhousen' }
    r.given_name { 'Klein' }
  end
  factory :aaron_mccartan, :class => Member do |r|
    r.iac_id { 433420 }
    r.family_name { 'McCartan' }
    r.given_name { 'Aaron' }
  end
### Judge
  factory :judge do |r|
    r.association :judge, :factory => :member
    r.association :assist, :factory => :member
  end
  factory :judge_jim, :class => Judge do |r|
    r.association :judge, :factory => :jim_wells
  end
  factory :judge_klein, :class => Judge do |r|
    r.association :judge, :factory => :klein_gilhousen
  end
  factory :judge_lynne, :class => Judge do |r|
    r.association :judge, :factory => :lynne_stoltenberg
  end
### Contest
  factory :nationals, :class => Contest do |r|
    r.name { 'U.S. National Aerobatic Championships' }
    r.city { 'Denison' }
    r.state { 'TX' }
    r.start { '2011-09-25' }
    r.director { 'Vicky Benzing' }
  end
  factory :contest do
    name { contest_name }
    city { Faker::Address.city }
    region { region_name }
    chapter { chapter_number }
    state { Faker::Address.state_abbr }
    start { Faker::Date.between(from: 6.years.ago, to: 3.years.from_now) }
    director { Faker::Name.name }
  end
### Category
  factory :category do
    transient do 
      category { 'Intermediate' }
      aircat { 'P' }
    end
    initialize_with do
      factory_cat = Category.where(:category => category, :aircat => aircat).first
      unless factory_cat
        sequence = Category.select('MAX sequence').first.sequence + 1
        factory_cat = Category.create(:category => cat, :aircat => aircat, :sequence => sequence)
      end
      factory_cat
    end
  end
### Flight
  factory :flight do |r|
    r.association :contest
    r.association :category
    r.name { 'Known' }
    r.sequence(:sequence)
    r.association :chief, :factory => :member
    r.association :assist, :factory => :member
  end
  factory :nationals_imdt_known, :class => Flight do |r|
    r.association :contest, :factory => :nationals
    r.association :category
    r.name { 'Known' }
    r.sequence(:sequence) { |n| n }
  end
  factory :nationals_imdt_free, :class => Flight do |r|
    r.association :contest, :factory => :nationals
    r.association :category
    r.name { 'Free' }
    r.sequence(:sequence) { |n| n }
  end
### Sequence
  factory :sequence do |r|
    r.figure_count { 5 }
    r.total_k { 61 }
    r.mod_3_total { 8 }
    r.k_values { [22,10,14,17,8] }
  end
  factory :imdt_known_seq, :class => Sequence do |r|
    r.figure_count { 14 }
    r.total_k { 201 }
    r.mod_3_total { 15 }
    r.k_values { [22,10,14,17,18,25,25,14,9,16,13,6,4,8] }
  end
  factory :adams_imdt_free_seq, :class => Sequence do |r|
    r.figure_count { 14 }
    r.total_k { 198 }
    r.mod_3_total { 15 }
    r.k_values { [18, 18, 15, 15, 11, 17, 15, 11, 10, 13, 11, 19, 17, 8] }
  end
  factory :denton_imdt_free_seq, :class => Sequence do |r|
    r.figure_count { 16 }
    r.total_k { 198 }
    r.mod_3_total { 12 }
    r.k_values { [10, 13, 9, 9, 18, 10, 19, 19, 18, 14, 18, 13, 10, 6, 4, 8] }
  end
### PilotFlight
  factory :pilot_flight, :class => PilotFlight do |r|
    r.association :pilot, :factory => :member
    r.association :flight
    r.association :sequence
    r.association :airplane
    r.penalty_total { 0 }
    r.chapter { '52' }
  end
  factory :adams_known, :class => PilotFlight do |r|
    r.association :pilot, :factory => :tom_adams
    r.association :flight, :factory => :nationals_imdt_known
    r.association :sequence, :factory => :imdt_known_seq
    r.penalty_total { 0 }
  end
  factory :denton_known, :class => PilotFlight do |r|
    r.association :pilot, :factory=> :bill_denton
    r.association :flight, :factory=> :nationals_imdt_known
    r.association :sequence, :factory=> :imdt_known_seq
    r.penalty_total { 20 }
  end
  factory :adams_free, :class => PilotFlight do |r|
    r.association :pilot, :factory=> :tom_adams
    r.association :flight, :factory=> :nationals_imdt_free
    r.association :sequence, :factory=> :adams_imdt_free_seq
    r.penalty_total { 0 }
  end
  factory :denton_free, :class => PilotFlight do |r|
    r.association :pilot, :factory=> :bill_denton
    r.association :flight, :factory=> :nationals_imdt_free
    r.association :sequence, :factory=> :denton_imdt_free_seq
    r.penalty_total { 0 }
  end
### Score
  factory :score do |r|
    r.association :pilot_flight
    r.association :judge
    r.values { [100, 100, 100, 95, 90] }
  end
  factory :denton_known_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_jim
    r.values { [100, 100, 100, 95, 90, 90, 85, 100, 100, 75, 90, 95, 100, 90] }
  end
  factory :denton_known_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_lynne
    r.values { [70, 70, 80, 90, 80, 100, 85, 85, 85, 90, 75, 90, 85, 80] }
  end
  factory :denton_known_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_klein
    r.values { [75, 80, 80, 85, 85, 75, 85, 85, 90, 80, 85, 85, 75, 80] }
  end
  factory :adams_known_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_jim
    r.values { [95, 100, 100, 90, 90, 85, 85, 100, 100, 90, 85, 85, 90, 95] }
  end
  factory :adams_known_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_lynne
    r.values { [85, 95, 85, 90, 90, 95, 75, 85, 100, 80, 95, 80, 90, 100] }
  end
  factory :adams_known_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_klein
    r.values { [100, 90, 85, 85, 85, 90, 80, 90, 90, 85, 85, 90, 85, 90] }
  end
  factory :denton_free_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_free
    r.association :judge, :factory => :judge_jim
    r.values { [100, 90, 100, 100, 70, 95, 95, 90, 90, 95, 90, 100, 95, 100, 90, 85] }
  end
  factory :denton_free_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_free
    r.association :judge, :factory => :judge_lynne
    r.values { [85, 85, 95, 90, 90, 100, 80, 85, 90, 85, 85, 85, 90, 100, 80, 100] }
  end
  factory :denton_free_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_free
    r.association :judge, :factory => :judge_klein
    r.values { [85, 90, 85, 85, 85, 80, 85, 85, 85, 85, 90, 80, 90, 90, 85, 90] }
  end
  factory :adams_free_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_free
    r.association :judge, :factory => :judge_jim
    r.values { [90, 90, 95, 95, 95, 85, 85, -10, 90, 100, 80, 85, 95, 90] }
  end
  factory :adams_free_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_free
    r.association :judge, :factory => :judge_lynne
    r.values { [85, 70, 85, 85, 85, 80, 75, 85, 85, 85, 85, 80, 95, 95] }
  end
  factory :adams_free_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_free
    r.association :judge, :factory => :judge_klein
    r.values { [75, 80, 80, 85, 85, 85, 85, 85, 80, 80, 85, 80, 85, 85] }
  end
### PfjResult
  factory :pfj_result do |r|
    r.association :pilot_flight
    r.association :judge
    r.graded_values { [75, 80, 80, 85, 85, 85, 85, 85, 80, 80, 85, 80, 85, 85] }
  end
  factory :existing_pfj_result, :class => PfjResult do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_jim
    r.computed_values { [2090, 1000, 1400, 1530, 1620, 2125, 2125,
      1400, 900, 1440, 1105, 510, 360, 760] }
    r.flight_value { 18365 }
  end
### PcResult
  factory :pc_result do |r|
    r.association :contest
    r.association :category, :category => 'Advanced'
    r.association :pilot, :factory => :member
  end
  factory :existing_pc_result, :class => PcResult do |r|
    r.association :contest, :factory => :nationals
    r.association :category, :category => 'Intermediate'
    r.association :pilot, :factory => :tom_adams
    r.category_value { 4992.14 }
    r.category_rank { 1 }
  end
### JfResult
  factory :jf_result do |r|
    r.association :judge, :factory => :judge
    r.association :flight, :factory => :flight
  end
### JcResult
  factory :jc_result do |r|
    r.association :judge, :factory => :member
    r.association :contest
    r.association :category, :category => 'Advanced'
  end
### JyResult
  factory :jy_result do |r|
    r.association :judge, :factory => :member
    r.association :category
  end
### DataPost
  factory :data_post do |r|
    r.association :contest
  end
### Result
  factory :result do |r|
    r.association :pilot, :factory => :member
    r.association :category
    r.year { 2014 }
    r.region { 'SouthCentral' }
    factory :result_with_members do
      after(:create) do |result, evaluator|
        create_list(:member, 4).each do |m|
          result.members << m
        end
      end
    end
    factory :result_with_accums do
      after(:create) do |result, evaluator|
        create_list(:pc_result, 4).each do |p|
          result.pc_results << p
        end
      end
    end
  end
### ResultMember
  factory :result_member do |r|
    r.association :result
    r.association :member
  end
### RegionalPilot
  factory :regional_pilot do |r|
    r.association :pilot, :factory => :member
    r.association :category
    r.region { 'NorthEast' }
    r.year { 2015 }
  end
### Failure
  factory :failure do |r|
    step { Faker::Food.dish }
    description { Faker::Hacker.say_something_smart }
    contest
  end
end
