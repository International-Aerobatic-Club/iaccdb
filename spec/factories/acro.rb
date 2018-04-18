# factories for the acro tests
FactoryBot.define do
  factory :existing_contest, :class => Contest do |c|
    c.name 'existingContest.yml'
    c.start '2010-09-21'
    c.city 'Denison'
    c.state 'TX'
    c.director 'Doug Lovell'
  end
end
