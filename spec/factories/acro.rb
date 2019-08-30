# factories for the acro tests
FactoryBot.define do
  factory :existing_contest, class: Contest do
    name { 'existingContest.yml' }
    start { '2010-09-21' }
    city { 'Denison' }
    state { 'TX' }
    director { 'Douglas Lovell' }
  end
end
