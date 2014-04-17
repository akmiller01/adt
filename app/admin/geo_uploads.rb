ActiveAdmin.register GeoUpload do
  actions :all, :except => [:new, :edit]

  menu :parent => "Geocoding"

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  controller do
     # When a geo_upload is deleted:
     # associated geocodes, unused geo_names, and unused geometries are deleted
    def destroy
      geocodes = Geocode.find_all_by_geo_upload_id(params[:id])
      geocodes.each do |geocode|
        geoname = GeoName.joins(:geocodes).where(id: geocode.geo_name_id)
        if geoname.count == 1
          GeoName.find(geocode.geo_name_id).delete
        end
        if !geocode.geometry_id.nil?
          geometry = Geometry.find(geocode.geometry_id)
          if geometry.adm_code.nil?
            geometry.delete
          end
        end
        geocode.delete
      end

      GeoUpload.find(params[:id]).delete

      redirect_to :action => 'index'
    end
  end

   # Import csv
  collection_action :import_csv, :method => :post do
    geo_upload = GeoUpload.create(csv: params[:dump][:file], record_count: 0, log_errors: 0)
    log_path = Rails.root.join('tmp')
    logfile = Tempfile.new('geo_upload.log', log_path)
    logfile.write("Geo Uploads Logfile:\n")
    record_stats = {"record_total" => 0,
                    "uploaded_record_count" => 0,
                    "missing_adms" => 0,
                    "deprecated_precisions" => 0,
                    "duplicate_geocodes" => 0}

    SmarterCSV.process(params[:dump][:file].tempfile,
                           {:chunk_size => 100,
                            :remove_unmapped_keys => true,
                            :key_mapping => {:geo_name_id => :geo_name_id,
                                             :geo_name => :geo_name,
                                             :project_id => :project_id,
                                             :precision => :precision_id,
                                             :latitude => :latitude,
                                             :longitude => :longitude,
                                             :location_type => :location_type }
                           }
    ) do |chunk|
      # perhaps refactor to work on geo_upload object
      record_stats = GeoUpload.csv_to_database(chunk, geo_upload, logfile, record_stats)
    end
    geo_upload.record_count = record_stats["uploaded_record_count"]
    geo_upload.log_errors = record_stats["missing_adms"] + record_stats["deprecated_precisions"] + record_stats["duplicate_geocodes"]

    logfile.write("\nSummary Statistics:\n")
    logfile.write("#{geo_upload.record_count} out of #{record_stats["record_total"]} records added to the database.\n")
    logfile.write("#{record_stats["missing_adms"]} records could not find an adm or geometry.\n")
    logfile.write("#{record_stats["deprecated_precisions"]} records have a deprecated precision code.\n")
    logfile.write("#{record_stats["duplicate_geocodes"]} records have the same project_id and geo_name_id as existing records.\n")
    logfile.read # fixes bug that prevents log file text being saved.
    geo_upload.log = logfile

    geo_upload.save
    redirect_to :action => :index, :notice => "CSV imported successfully!"
  end

  index do
    column :id
    column :record_count
    column "CSV File", :csv_file_name do |csv|
      link_to(csv.csv_file_name, csv.csv.url)
    end
    column :csv_content_type
    column "CSV File Size", :csv_file_size do |csv|
      number_to_human_size(csv.csv_file_size)
    end
    column "Log File", :log_file_name do |log|
      link_to(log.log_file_name, log.log.url)
    end
    column :log_errors
    column :created_at
    column :updated_at

    actions defaults: false do |post|
      link_to 'Delete', admin_geo_upload_path(post), :method => :delete,
              :confirm => 'WARNING: Deleting this record will delete all geocodes generated from this upload!'
    end
  end
  
end
