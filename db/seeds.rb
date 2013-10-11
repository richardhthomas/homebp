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
    "Capoten" => "Captopril",
    "Vascace" => "Cilazapril",
    "Innovace" => "Enalapril Maleate",
    "Fosinopril Sodium" => "Fosinopril Sodium",
    "Tanatril" => "Imidapril Hydrochloride",
    "Zestril" => "Lisinopril",
    "Perdix" => "Moexipril Hydrochloride",
    "Perindopril Erbumine" => "Perindopril Erbumine",
    "Coversyl Arginine" => "Perindopril Arginine",
    "Accuretic" => "Quinapril",
    "Accupro" => "Quinapril",
    "Tritace" => "Ramipril",
    "Gopten" => "Trandolapril" 
  },
  
  "Angiotensin II receptor antagonists" => {
    "Erdabi" => "Azilsartan Medoxomil",
    "Amias" => "Candesartan Cilexitil",
    "Teveten" => "Eprosartan",
    "Aprovel" => "Irbesartan",
    "Cozaar" => "Losartan Potassium",
    "Olmetec" => "Olmesartan Medoxomil",
    "Micardis" => "Telmisartan",
    "Diovan" => "Valsartan"
  },
  
  "Diuretics" => {
    "Bendroflumethiazide" => "Bendroflumethiazide",
    "Hygroton" => "Chlortalidone",
    "Navidrex" => "Cyclopenthiazide",
    "Natrilix" => "Indapamide",
    "Ethibide" => "Indapamide", 
    "Natrilix SR" => "Indapamide",
    "Tensaid XL" => "Indapamide",
    "Metenix 5" => "Metolozone",
    "Diurexan" => "Xipamide"
  },
  
  "Beta-blockers" => {
    "Half-Inderal LA" => "Propranalol",
    "Inderal LA" => "Propranalol",
    "Sectral" => "Acebutolol",
    "Tenormin" => "Atenolol",
    "Cardicor" => "Bisoprolol Fumarate",
    "Emcor" => "Bisoprolol Fumarate",
    "Eucardic" => "Carvedilol",
    "Celectol" => "Celiprolol Hydrochloride",
    "Brevibloc" => "Esmolol Hydrochloride",
    "Trandate" => "Labetolol Hydrochloride",
    "Betaloc" => "Metoprolol Tartrate",
    "Lopresor" => "Metoprolol Tartrate",
    "Lopresor SL" => "Metoprolol Tartrate",
    "Corgard" => "Nadolol",
    "Nebilet" => "Nebivolol",
    "Trasicor" => "Oxprenolol Hydrochloride",
    "Slow-Trasicor" => "Oxprenolol Hydrochloride",
    "Visken" => "Pindolol",
    "Beta-cardone" => "Sotalol Hydrochloride",
    "Sotacor" => "Sotalol Hydrochloride",
    "Betim" => "Timolol"
  },
  
  "Alpha-blockers" => {
    "Cardura" => "Doxazosin",
    "Cardura XL" => "Doxazosin",
    "Doralese" => "Indoramin",
    "Hypovase" => "Prazosin",
    "Hytrin" => "Terazosin"
  }
}

groups = drug_names.keys
groups.each do |group|
  drug_names[group].each do |brand, generic|
    Drug.create( brand: brand, generic: generic, group: group )
  end
end
