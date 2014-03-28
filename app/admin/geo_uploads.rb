ActiveAdmin.register GeoUpload do
  menu :parent => "Geocoding"

  action_item :only => :index do
    link_to 'Upload CSV', :action => 'upload_csv'
  end

  collection_action :upload_csv do
    render "admin/csv/upload_csv"
  end

  collection_action :import_csv, :method => :post do
    n = SmarterCSV.process(params[:dump][:file].tempfile,
                           {:remove_unmapped_keys => true,
                            :key_mapping => {:geo_name_id => :geo_name_id, :geo_name => :geo_name, :project_id => :project_id,
                                             :precision => :precision_id, :latitude => :latitude,  :longitude => :longitude,
                                             :location_type => :location_type }}) do |chunk|
      chunk.each do |record|
        geocode = {}
        geocode[:precision_id] = record[:precision_id]
        geocode[:project_id] = record[:project_id]
        geocode[:geo_upload_id] = params[:id]

        location_type = LocationType.find_by_name(record[:location_type])

         # We don't want duplicate geo_names.
         # We assume that new is better.
         # So new geo_name info should replace old geo_names with the same code.
        old_geo_name = GeoName.find_by_code(record[:geo_name_id])
        if !old_geo_name.nil?
          old_geo_name.name = record[:geo_name]
          old_geo_name.code = record[:geo_name_id]
          old_geo_name.latitude = record[:latitude]
          old_geo_name.longitude = record[:longitude]

          # Determine location type for geo_name
          if !location_type.nil?
            geo_name[:location_type_id] = location_type.id
          end

          geocode[:geo_name_id] = old_geo_name.id
        else
          geo_name = {}
          geo_name[:name] = record[:geo_name]
          geo_name[:code] = record[:geo_name_id]
          geo_name[:latitude] = record[:latitude]
          geo_name[:longitude] = record[:longitude]

          # Determine location type for geo_name
          if !location_type.nil?
            geo_name[:location_type_id] = location_type.id
          end

          new_geo_name = GeoName.create( geo_name )
          geocode[:geo_name_id] = new_geo_name.id
        end

        puts record

        factory = RGeo::Cartesian.factory
        lonlat = factory.point(record[:longitude], record[:latitude])

        geometry = {}
        if record[:precision_id] == 1  # its a point
          geometry[:the_geom] = RGeo::Feature.cast(lonlat, RGeo::Feature::GeometryCollection)
          new_geometry = Geometry.create ( geometry )
          geocode[:geometry_id] = new_geometry.id

        elsif record[:precision_id] == 2  # its a buffer within 25km
          lonlat_buff = lonlat.buffer(25000)
          geometry[:the_geom] = RGeo::Feature.cast(lonlat_buff, RGeo::Feature::GeometryCollection)

          new_geometry = Geometry.create ( geometry )
          geocode[:geometry_id] = new_geometry.id

        elsif record[:precision_id] == 3  # its an adm2
          adms = Adm.joins(:geometry).where(level: 2)
          adms.each do |adm|
            the_geom = adm.the_geom
            if the_geom.contains?(lonlat)
              geocode[:geometry_id] = adm.geometry_id
              geocode[:adm_id] = adm.id  # make sure this is correct
            end
          end

        elsif record[:precision_id] == 4  # its an adm1
          adms = Adm.joins(:geometry).where(level: 1)
          adms.each do |adm|
            the_geom = adm.the_geom
            if the_geom.contains?(lonlat)
              geocode[:geometry_id] = adm.geometry_id
              geocode[:adm_id] = adm.id  # make sure this is correct
            end
          end

        elsif record[:precision_id] == (6 || 8)  # its an adm0
          adms = Adm.joins(:geometry).where(level: 0)
          adms.each do |adm|
            the_geom = adm.the_geom
            if the_geom.contains?(lonlat)
              geocode[:geometry_id] = adm.geometry_id
              geocode[:adm_id] = adm.id  # make sure this is correct
            end
          end
        end

        Geocode.create( geocode )
      end
      #puts chunk.inspect   # we could at this point pass the chunk to a Resque worker..
    end
    redirect_to :action => :index, :notice => "CSV imported successfully!"
  end

  index do
    column :id
    column :record_count
    column :csv_file_name
    column :csv_content_type
    column "CSV File Size", :csv_file_size do |csv|
      number_to_human_size(csv.csv_file_size)
    end
    column :created_at
    column :updated_at
    default_actions
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "CSV" do
      f.input :csv, :as => :file
    end
    f.buttons
  end
  
end
