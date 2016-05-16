# use rails runner
# sets aircat for four minute free category value to 'F'
# Four minute free is agnostic regarding power or glider
# It should not be either class

Category.where('category like "%four%"').each do |cat|
  cat.aircat = 'F'
  cat.save!
end

