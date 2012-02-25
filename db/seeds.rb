# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
Category.create([
  {:sequence => 1, :aircat => 'P', :category => 'primary', 
   :name => 'Primary Power' },
  {:sequence => 2, :aircat => 'P', :category => 'sportsman', 
   :name => 'Sportsman Power' },
  {:sequence => 3, :aircat => 'P', :category => 'intermediate', 
   :name => 'Intermediate Power' },
  {:sequence => 4, :aircat => 'P', :category => 'advanced', 
   :name => 'Advanced Power' },
  {:sequence => 5, :aircat => 'P', :category => 'unlimited', 
   :name => 'Unlimited Power' },
  {:sequence => 6, :aircat => 'G', :category => 'sportsman', 
   :name => 'Sportsman Glider' },
  {:sequence => 7, :aircat => 'G', :category => 'intermediate', 
   :name => 'Intermediate Glider' },
  {:sequence => 8, :aircat => 'G', :category => 'advanced', 
   :name => 'Advanced Glider' },
  {:sequence => 9, :aircat => 'G', :category => 'unlimited', 
   :name => 'Unlimited Glider' },
  {:sequence => 10, :aircat => 'P', :category => 'four minute', 
   :name => 'Four Minute Free' }])
