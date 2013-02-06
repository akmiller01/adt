namespace :projects do
  # Create Intents #
	desc "Create intents"
	task :create_intents => :environment do
	
    ["Development", "Commercial", "Representational", "Mixed"].each do |n|
      Intent.create!(name: n)
    end
  end
		
	desc "Update FlowClass with old_oda_like"
	task :old_oda_like_to_flow_class => :environment do
	
		progress_bar = ProgressBar.new(Project.count)
		
		p "Updating new oda_like if it doesn't match the old oda_like..."
		
		CACHE_ALL=false
		Project.all.each do |p|
			if !(p.oda_like==p.old_oda_like) 
				p.oda_like=p.old_oda_like
				p.save
			end
			progress_bar.increment!
		end
		
		CACHE_ALL=true
		Project.first.save
	end

	desc "Create Loan Types"
	task :create_loan_types => :environment do
	
    ["Interest-Free", "Concessional", 
     "Non-Concessional", "No Information"].each do |n|
      LoanType.create!(name: n)
    end

	desc "Apply is_cofinanced variable, which was missed by import script"
	task :apply_is_cofinanced => :environment do

cofinanced_ids = [
19874,538,14795,18763,21374,
28153,304,1250,914,15093,2050,2055,20669,1407,1735,24832,868,17166,18864,1960,2140,
215,335,21334,14868,21355,1619,19641,2424,1151,15658,19300,23554,
1034,1348,16829,14303,17764,18121,18271,19906,11391,21341,149,856,1137,1174,
1649,1830,2092,21348,19884,227,14709,2459,22211,1738,1136,22279,1988]

		CACHE_ALL = false
		Project.where("id in (?)", cofinanced_ids).each{ |p| p.update_attribute :is_cofinanced, true}
		CACHE_ALL = true
		Project.first.cache!
		p "finished applying."
	end


	desc "Make year_uncertain=True where year is null"
	task :year_uncertain_when_null => :environment do


		CACHE_ALL = false
		Project.where("year is null").each{ |p| p.update_attribute :year_uncertain, true}
		CACHE_ALL = true
		Project.first.cache!
		p "finished applying."
	end
end

	desc "Relace &amp; with &"
	task :repair_ampersand => :environment do

	c = 0
	ids = []

	Project.where("description like '%&amp;%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/&amp;/, ' '))
		ids.push p.id
		c+=1
	end
		
	
	p "#{c} ampersands corrected."
	p ids
	
	end

	desc "Remove style definitions from description text"
	task :remove_style_definitions => :environment do

	c = 0
	ids = []
	
	Project.where("description like '%Style Definitions%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/Normal  0.+}/, ' '))
		ids.push p.id
		c+=1
	end
	
	p "#{c} style definitions removed."
	p ids
	end

	desc "Remove PPIAF"
	task :remove_ppiaf => :environment do

	c = 0
	ids = []
	
	Project.where("description like '%PPIAF%' or title like '%PPIAF%'").each do |p|
		p.update_attribute(:description, p.description.gsub(/PPIAF/, ''))
		p.update_attribute(:title, p.title.gsub(/[\(]PPIAF(\sID\s\d+|\s-\s)[\)]/, ''))
		ids.push p.id
		c+=1
	end
	
	p "#{c} PPIAFs removed."
	p ids
	end

  desc "Create Flag Types"
  task :create_flag_types => :environment do

    puts "Creating Flag types"
    FlagType.create!(name: "Challenge", color: 'red')
    FlagType.create!(name: "Confirm", color: 'green')
  end
end

task :projects => ["projects:old_oda_like_to_flow_class",
  "projects:create_intents","projects:create_loan_types",
  "projects:create_flag_types"]