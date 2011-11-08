# factories for the acro tests
FactoryGirl.define do
  factory :tom_adams, :class => Member do |r|
    r.iac_id 1999
    r.family_name 'Adams'
    r.given_name 'Tom'
  end
  factory :bill_denton, :class => Member do |r|
    r.iac_id 9821
    r.family_name 'Denton'
    r.given_name 'Bill'
  end
  factory :lynne_stoltenberg, :class => Member do |r|
    r.iac_id 431354
    r.family_name 'Stoltenberg'
    r.given_name 'Lynne'
  end
  factory :jim_wells, :class => Member do |r|
    r.iac_id 20352
    r.family_name 'Wells'
    r.given_name 'Jim'
  end
  factory :klein_gilhousen, :class => Member do |r|
    r.iac_id 21489
    r.family_name 'Gilhousen'
    r.given_name 'Klein'
  end
  factory :aaron_mccartan, :class => Member do |r|
    r.iac_id 433420
    r.family_name 'McCartan'
    r.given_name 'Aaron'
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
  factory :nationals, :class => Contest do |r|
    r.name 'U.S. National Aerobatic Championships'
    r.city 'Denison'
    r.state 'TX'
    r.start '2011-09-25'
    r.director 'Vicky Benzing'
  end
  factory :contest do |r|
    r.sequence(:name) { |n| "Test contest #{n}" }
    r.city 'Danbury'
    r.state 'Connecticut'
    r.start '2011-09-25'
    r.director 'Ron Chadwick'
  end
  factory :nationals_imdt_known, :class => Flight do |r|
    r.association :contest, :factory => :nationals
    r.category 'Intermediate'
    r.name 'Known'
    r.sequence(:sequence) { |n| n }
    r.aircat 'P'
  end
  factory :imdt_known_seq, :class => Sequence do |r|
    r.figure_count 14
    r.total_k 201
    r.mod_3_total 15
    r.k_values [22,10,14,17,18,25,25,14,9,16,13,6,4,8]
  end
  factory :adams_known, :class => PilotFlight do |r|
    r.association :pilot, :factory => :tom_adams
    r.association :flight, :factory => :nationals_imdt_known
    r.association :sequence, :factory => :imdt_known_seq
    r.penalty_total 0
  end
  factory :denton_known, :class => PilotFlight do |r|
    r.association :pilot, :factory=> :bill_denton
    r.association :flight, :factory=> :nationals_imdt_known
    r.association :sequence, :factory=> :imdt_known_seq
    r.penalty_total 20
  end
  factory :denton_known_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_jim
    r.values [100, 100, 100, 95, 90, 90, 85, 100, 100, 75, 90, 95, 100, 90]
  end
  factory :denton_known_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_lynne
    r.values [70, 70, 80, 90, 80, 100, 85, 85, 85, 90, 75, 90, 85, 80]
  end
  factory :denton_known_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :denton_known
    r.association :judge, :factory => :judge_klein
    r.values [75, 80, 80, 85, 85, 75, 85, 85, 90, 80, 85, 85, 75, 80]
  end
  factory :adams_known_jim, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_jim
    r.values [95, 100, 100, 90, 90, 85, 85, 100, 100, 90, 85, 85, 90, 95]
  end
  factory :adams_known_lynne, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_lynne
    r.values [85, 95, 85, 90, 90, 95, 75, 85, 100, 80, 95, 80, 90, 100]
  end
  factory :adams_known_klein, :class => Score do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_klein
    r.values [100, 90, 85, 85, 85, 90, 80, 90, 90, 85, 85, 90, 85, 90]
  end
  factory :existing_pfj_result, :class => PfjResult do |r|
    r.association :pilot_flight, :factory => :adams_known
    r.association :judge, :factory => :judge_jim
    r.computed_values [2090, 1000, 1400, 1530, 1620, 2125, 2125,
      1400, 900, 1440, 1105, 510, 360, 760]
    r.flight_value 18365
  end
end
