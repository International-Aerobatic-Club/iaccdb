# factories for the acro tests
FactoryGirl.define do
  factory :existing_contest, :class => Contest do |c|
    c.name 'The existing contest matches existingContest.yml'
    c.start '2010-09-21'
    c.city 'Denison'
    c.state 'TX'
    c.director 'Doug Lovell'
  end
end
