# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# List of drugs and their generic / brand names
drug_names = {
  "Calcium channel blockers" => {
    "Istin" => "Amlodipine",
    "Adizem-SR" => "Diltiazem",
    "Adizem-XL" => "Diltiazem",
    "Angitil SR" => "Diltiazem",
    "Angitil XL" => "Diltiazem",
    "Calcicard CR" => "Diltiazem",
    "Dilcardia SR" => "Diltiazem",
    "Dilzem SR" => "Diltiazem",
    "Dilzem XL" => "Diltiazem",
    "Slozem" => "Diltiazem",
    "Tildiem LA" => "Diltiazem",
    "Tildiem Retard" => "Diltiazem",
    "Viazem XL" => "Diltiazem",
    "Zemtard" => "Diltiazem",
    "Plendil" => "Felodipine",
    "Prescal" => "Isradipine",
    "Motens" => "Lacidipine",
    "Zanidip" => "Lercanidipine Hydrochloride",
    "Cardene" => "Nircadipine Hydrochloride",
    "Cardene SR" => "Nircadipine Hydrochloride",
    "Adalat" => "Nifedipine",
    "Adalat LA" => "Nifedipine",
    "Adalat Retard" => "Nifedipine",
    "Adipine MR" => "Nifedipine",
    "Coracten SR" => "Nifedipine",
    "Coracten XL" => "Nifedipine",
    "Fortipine LA 40" => "Nifedipine",
    "Nifedipress MR" => "Nifedipine",
    "Tensipine MR" => "Nifedipine",
    "Valni XL" => "Nifedipine",
    "Nimotop" => "Nimodipine",
    "Cordilox" => "Verapamil Hydrochloride",
    "Securon" => "Verapamil Hydrochloride",
    "Half Securon SR" => "Verapamil Hydrochloride",
    "Securon SR" => "Verapamil Hydrochloride",
    "Univer" => "Verapamil Hydrochloride",
    "Verapress MR" => "Verapamil Hydrochloride",
    "Vertab SR 240" => "Verapamil Hydrochloride"
  },
  "ACE inhibitors" => {
    "Tritace" => "Ramipril"
  }
}

groups = drug_names.keys
groups.each do |group|
  drug_names[group].each do |brand, generic|
    Drug.create( brand: brand, generic: generic, group: group )
  end
end
