class Status < ActiveRecord::Base
  attr_accessible :iati_code, :name, :code
  has_paper_trail
  default_scope order: "name"	


  has_many :projects
end