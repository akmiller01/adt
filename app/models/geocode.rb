class Geocode < ActiveRecord::Base
  attr_accessible :geo_name_id, :precision_id, :project_id, :geometry_id, :geo_upload_id, :adm_id

  belongs_to :geo_name
  belongs_to :precision
  belongs_to :project
  belongs_to :geometry
  belongs_to :geo_upload
  belongs_to :adm

  has_many :flags, as: :flaggable, dependent: :destroy
  accepts_nested_attributes_for :flags

end
