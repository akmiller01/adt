class LocationType < ActiveRecord::Base
  attr_accessible :name

  has_many :geocodes
end
