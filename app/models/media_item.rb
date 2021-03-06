class MediaItem < ActiveRecord::Base

  belongs_to :project
  belongs_to :user
  belongs_to :media_source_type
  attr_accessible :project_id, :publish, :media, :user_id, :downloadable, :url, :featured,
                  :homepage_text, :download_text, :media_source_type_id, :on_homepage,
                  :media_file_name, :media_content_type, :media_file_size, :media_updated_at

  # for paperclip
  has_attached_file :media, :styles => { :project_size => "350x350>", :home_size => "320x320>", :thumb => "100x100>" }


  validates_attachment :media,
                       :content_type => { :content_type => ["image/jpeg", "image/gif", "image/png"],
                                          :if => :publish?,
                                          :message => "Only images and youtube videos can be published" },
                       :size => { :in => 0..20.megabytes, :message => "must be less than 20 MB"  }

  validates_attachment_content_type :media,
                                    :content_type => ["image/jpeg", "image/gif", "image/png"],
                                    :if => :on_homepage,
                                    :message => "Only images and youtube videos can be displayed on homepage"

  # add validations for downloadable and publish based on content types
  #validates_presence_of :url, :unless => :media? # Bug: This validation prevents other styles besides original from being stored.
  #validates_presence_of :media, :unless => :url? # Bug: This validation prevents other styles besides original from being stored.
  validates_presence_of :homepage_text, :if => :on_homepage?
  validates_presence_of :download_text, :if => :downloadable?
  validates_presence_of :publish, :if => :featured?
  validates_presence_of :media_source_type_id, :if => :downloadable?
  validates_format_of :url, :with =>  /^(http|https):\/\/www\.youtube\.com\/watch\?v=([a-zA-Z0-9_-]*)/,
                      :message => "Must be youtube url", :if => :publish?, :allow_blank => true

  def youtube_embed(youtube_url,height,width,iframe_id)
    if youtube_url[/youtu\.be\/([^\?]*)/]
      youtube_id = $1
    else
      # Regex from # http://stackoverflow.com/questions/3452546/javascript-regex-how-to-get-youtube-video-id-from-url/4811367#4811367
      youtube_url[/^.*((v\/)|(embed\/)|(watch\?))\??v?=?([^\&\?]*).*/]
      youtube_id = $5
    end

    %Q{<iframe id="slide_#{ iframe_id}" title="YouTube video player" width="#{ width }" height="#{ height }" src="http://www.youtube.com/embed/#{ youtube_id }" frameborder="0" allowfullscreen="false"></iframe>}
  end

end
