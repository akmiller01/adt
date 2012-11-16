Factory.define :comment do |c|
  c.name 'Brad Parks'
  c.email 'bparks@aiddata.org'
  c.content 'Lorem ipsum'
end


Factory.define :status do |s|
  s.name 'Cancelled'
  s.iati_code '5'
end

Factory.define :verified do |v|
  v.name 'Suspicious'
end

Factory.define :oda_like do |o|
  o.name 'OOF-Like'
end
 
Factory.define :flow_type do |f|
  f.name 'Grant'
  f.iati_code 1 #these are bogus numbers
  f.oecd_code 10
  f.aiddata_code 10454
end

Factory.define :tied do |t|
  t.name 'Partially Tied'
  t.iati_code 5
end

Factory.define :sector do |s|
  s.name 'Education'
end

Factory.define :country do |c|
  country_name = Faker::Address.country
  c.name country_name
  c.iso3 country_name[0..2].upcase
end

Factory.define :source_type do |s|
  s.name 'Factiva'
end

Factory.define :document_type do |d|
  d.name "International media report"
end

Factory.define :organization do |o|
  o.name Faker::Company.name
  o.description Faker::Company.catch_phrase
end

Factory.define :role do |r|
  names = ["Implementing", "Funding", "Executing", "Accountable"]
  r.name  names.sample
  r.iati_code rand(1..5)
end

Factory.define :source do |s|
  s.url 'www.cnn.com'
  s.document_type FactoryGirl.create(:document_type)
  s.source_type FactoryGirl.create(:source_type)
  s.date 1.day.ago
end


Factory.define :user do |user|
  user.name                  "rmosolgo"
  user.email                 "rmosolgo@aiddata.org"
  user.password              "foobar"
  user.password_confirmation "foobar"
  user.owner FactoryGirl.create(:organization)
end

Factory.define :currency do |currency|
  country_name = Faker::Address.country
  currency_name = Faker::Lorem.words[0]
  currency.name "#{country_name} #{currency_name.capitalize}"
  currency.iso3 currency_name[0..2].upcase
end

Factory.define :contact do |c|
  c.name "Hu Jintao"
  c.position "President"
  c.organization Organization.first
end

Factory.define :transaction do |transaction|
  transaction.value rand(1000..10000000)
  transaction.currency FactoryGirl.create(:currency)
end


Factory.define :geopolitical do |g|
  subnational_city = Faker::Address.city
  subnational_street = Faker::Address.street_name
  subnational_field = subnational_street+', '+subnational_city
  g.recipient FactoryGirl.create(:country)
  g.subnational subnational_field
  g.percent rand(0..50).round
end

Factory.define :participating_organization do |o|
  o.role  FactoryGirl.create(:role)
  o.organization  FactoryGirl.create(:organization)
end

Factory.define :project do |project|

  project.title "Example project title"
  project.description "Example description of a development project"
  project.active true
  project.start_actual 10.years.ago
  project.start_planned 11.years.ago
  project.end_planned 2.years.ago
  project.end_actual 1.year.ago
  project.year 2002
  project.is_commercial false

  project.status FactoryGirl.create(:status)
  project.verified FactoryGirl.create(:verified)
  project.oda_like FactoryGirl.create(:oda_like)
  project.flow_type FactoryGirl.create(:flow_type)
  project.tied FactoryGirl.create(:tied)
  project.sector FactoryGirl.create(:sector)

  project.donor FactoryGirl.create(:country)
  project.owner FactoryGirl.create(:organization)

end

Factory.define :cache do |cache|
	cache.id 1
	cache.text FactoryGirl.create(:project).cache_text
end
	


