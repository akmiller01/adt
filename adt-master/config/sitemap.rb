# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://aiddatachina.org" #"http://china.aiddata.org"

SitemapGenerator::Sitemap.create do
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Add static pages

    # The root path '/' and sitemap index file are added automatically for you.
    add bubbles_path
    add map_path

    # add content pages
    Content.find_each do |content|
      if ["Page", "Complex Page"].include? content.content_type
        add content_by_name_path(content.name), :changefreq => 'weekly'
      end
    end

  # Add '/projects'
  
     add projects_path, :priority => 0.7, :changefreq => 'daily'
  
  # Add all projects:

    Project.find_each do |project|
       add project_path(project), :lastmod => project.updated_at, :changefreq => 'daily'
    end

    
end