# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# List of drugs and their generic / brand names
drug_names = [
  [ "Istin", "Amlodipine" ],
  [ "Adizem-SR", "Diltiazem" ],
  [ "Adizem-XL", "Diltiazem" ],
  [ "Angitil SR", "Diltiazem" ]
]

drug_names.each do |brand, generic|
  Drug.create( brand: brand, generic: generic )
end