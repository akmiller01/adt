class Flag < ActiveRecord::Base
  attr_accessible :comment, :flag_type, :flag_type_id, :flaggable_id, 
    :flaggable_type, :owner_id, :owner, :source, :updated_at
  
  default_scope order: "updated_at"	
  after_destroy :recache_and_reindex_project
  after_save :recache_and_reindex_project

  belongs_to :flag_type
  belongs_to :flaggable, polymorphic: true
  belongs_to :owner, class_name: User
  
  has_paper_trail

  def name
  	flag_type ? flag_type.name : source
  end

  def project
    if ApplicationHelper::PROJECT_ACCESSORY_OBJECTS.include?(flaggable_type)
      flagged_object = flaggable_type.constantize.find(flaggable_id)
      flagged_object.project
    else
      Project.find(flaggable_id)
    end
  end

  def recache_and_reindex_project
    Sunspot.index(project)
    project.cache!
  end
end
