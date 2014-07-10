class Base64MediaItem < ActiveRecord::Base
  attr_accessible :media, :comment_id

  has_attached_file :media,
    :styles => {
        :large => "500x500>",
        :medium => "320x320>",
        :thumb => "100x100>"
    }

  has_one :comment
  #do_not_validate_attachment_file_type :media  #uncomment if upgrade paperclip to 4.1

end