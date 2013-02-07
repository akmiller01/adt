module ProjectCache
  include ProjectExporters
  require 'fileutils'

  def cache!
    File.open("1.txt", "w") {}
    if CACHE_ONE
      cached_record = Cache.find_or_create_by_id(id)
      cached_record.skip_cache_all = false
      cached_record.update_attribute(:text, self.csv_text)

    File.open("2.txt", "w") {}
      scopes = self.scope
      scopes.each { |s| cache_files(s) }

    end
  end
  handle_asynchronously :cache!

  def cache_one!
    if CACHE_ONE
      cached_record = Cache.find_or_create_by_id(id)
      cached_record.skip_cache_all = true
      cached_record.update_attribute(:text, self.csv_text)
    end
  end
  handle_asynchronously :cache_one!

  def cache_files(scope_name)
    #remove old file
    FileUtils.rm Dir.glob("public/downloads/*#{scope_name.to_s.capitalize}.csv"), :force => true

    File.open("3.txt", "w") {}
    file_prefix = "#{scope_name.to_s.capitalize}"
    # this prepends the last updated time to the filename, but
    # maybe that's not the best because people will think data is out of date
    # when it isn't
    #t = Time.now
    #file_prefix = "#{t.year}-#{t.month}-#{t.day}-" \
    #              "#{scope_name.to_s.capitalize}"

    File.open("public/downloads/#{file_prefix}.csv","w") do |f|
      f.puts "#{Project.csv_header}"
      Project.all.each do |project|
        if project.contains_scope?(scope_name)
          f.puts "#{project.csv_text}"
        end
      end
    end
    File.open("4.txt", "w") {}
  end
  handle_asynchronously :cache_files
end
