class AggregatesController < ApplicationController
	skip_before_filter :signed_in_user  
	def projects
		@valid_fields = [
			{external: "donor", internal: "donors.iso3", group: "donors.iso3"},
			{external: "year",  internal: "year", group: "year"},
			{external: "sector_name", internal: "(case when sectors.name is null then 'Unset' else sectors.name end)", group: "sectors.name"},
			{external: "recipient_name",   group: "recipient_name", internal: "recipient_name"},
			{external: "recipient_iso2",   group: "recipient_iso2", internal: "recipient_iso2"},
			{external: "recipient_iso3",   group: "recipient_iso3", internal: "recipient_iso3"},
			{external: "flow_class", group: "oda_likes.name", internal: "(case when oda_likes.name is null then 'Unset' else oda_likes.name end)"}
			# active 
		]
		
		@recipient_field_names = ["name", "iso2", "iso3"]
		
		@duplication_handlers = [
				# MERGE --> If a project has multiple recipients, call it "Africa, Regional"
				{external: "merge", 
						select: @recipient_field_names.map{ |fn| "(case when count(recipients.id) > 1 then 'Africa, regional' " +
									"else max(recipients.#{fn}) end) as recipient_#{fn}" }.join(", "), 
						group: "group by projects.id", 
						join: "INNER JOIN geopoliticals geo on projects.id = geo.project_id "+
									"INNER JOIN countries recipients on geo.recipient_id = recipients.id",
						amounts: 'round(sum(sum_usd_defl),2) as usd_2009, round(sum(sum_usd_current),2) as usd_current'
						}, 
								
				# PERCENT THEN MERGE --> If a project has multiple recipients and percentages add up to 100, 
				#															Then divide along those percentages
				#												 Else call it "Africa, Regional"
				{external: "percent_then_merge",
						select: @recipient_field_names.map { |fn| "(case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) != 100) then 'Africa, regional' else recipients.#{fn} end ) as recipient_#{fn}"}.join(', ') + ", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 else 1.0 end) as multiplier",
						group: "", 
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(sum(sum_usd_defl*p.multiplier), 2) as usd_2009, round(sum(sum_usd_current*p.multiplier), 2) as usd_current"
						 },
				 
				# PERCENT THEN SHARE --> If a project has multiple recipients and percentages add up to 100, 
				#															Then divide along those percentages
				#												 Else share it equally among recipients
				{external: "percent_then_share",
						select: @recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(', ') + 
									", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 else (select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id)/1.0 end) as multiplier",
						group: "",
						join:"LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(sum(sum_usd_defl*p.multiplier), 2) as usd_2009, round(sum(sum_usd_current*p.multiplier),2) as usd_current"
						 },
				
				# SHARE --> If a project has multiple recipients, share the amount equally among recipients
				{external: "share",
						select: @recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(', ') + ",(select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) as recipients_count" ,
						group: "", 
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: "round(sum(sum_usd_defl/p.recipients_count),2) as usd_2009, round(sum(sum_usd_current/p.recipients_count),2) as usd_current"
						},
						
				# DUPLICATE --> If a project has multiple recipients, allocate the full amount to each recipient (DOUBLE-COUNTING)
				{external: "duplicate",
						select: @recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(', ') ,
						group: "",
						join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
									"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
						amounts: 'round(sum(sum_usd_defl), 2) as usd_2009, round(sum(sum_usd_current),2) as usd_current'
						}
			]
		
		@duplication_scheme = @duplication_handlers.select { |h| h[:external] == "#{params[:multiple_recipients]}" }[0] || @duplication_handlers[0] 
		
		@fields_to_get = []
	
		if params[:get].class == String
			@get = params[:get].split(",")
		elsif params[:get].class == Array
			@get = params[:get]
		end
		
		#  &wdi=#{wdi_code} 

		if @get.include?("year") && @get.include?("recipient_iso3")
			if params[:wdi].class== String
				@wdi = params[:wdi].split(",")
			elsif params[:wdi].class== Array
				@wdi = params[:wdi]
			else 
				@wdi = []
			end
			@wdi = @wdi.map do |wdi_input| 
				if wdi_input.upcase == wdi_input.upcase[/[A-Z0-9\.]+/]
					wdi_input.upcase
				end 
			end
		end

		@valid_fields.each do |field|
	      	if @get.include?(field[:external]) 
	      		@fields_to_get.push field
	      	end
	 end

	    where_filters = [
	    	{sym: :recipient_iso2, options: Country.all.map{|c| c.iso2} , internal_filter: "recipient_iso2"},
	    	{sym: :sector_name, options:Sector.all.map{|c| c.name} , internal_filter: "sectors.name"},
	    	{sym: :verified, options: Verified.all.map{|c| c.name} , internal_filter: "verifieds.name"},
	    	{sym: :flow_type, options: FlowType.all.map{|c| c.name} , internal_filter: "flow_types.name"},
	    	{sym: :flow_class, options: OdaLike.all.map{|o| o.name}, internal_filter: "oda_likes.name" },
	    	{sym: :year, options: ("2000".."2010").to_a , internal_filter: "year" }
	    ]

	    @filters = ["active = 't' "]

	    where_filters.each do |wf|
	    	param_values = params[wf[:sym]] 
		    if param_values
		    	if param_values.class == String
		    		param_values = param_values.split(',')
		    	end

		    	if valid_values = (wf[:options] & param_values)
		    		@filters.push "#{wf[:internal_filter]} in ('#{valid_values.join("','")}')"
		    	end
		    end
		end


	    if !@fields_to_get.blank?  	
		    
		    # ---------- I really tried to do it right, but couldn't get it! --------------
		    #
		    # @data = Project.find( :all,
		    # 	select: "usd_defl as usd_2009, #{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}",
		    # 	group: "#{@fields_to_get.map{|f| f[:internal]}.join(', ')}",
		    # 	conditions: "active = 't'",
		    # 	joins: ["INNER JOIN countries donors ON donors.id = projects.donor_id ", 
		    # 			:transactions, :geopoliticals, :sector],
		    # 	limit: 100,
		    # 	order: nil
		    # 	    	)

		 	sql = "select #{@duplication_scheme[:amounts]}, count(*) as count,
		 			#{@fields_to_get.map{|f| f[:internal] + ' as ' + f[:external]}.join(', ')}
		 			from (select projects.*, 
		 					#{@duplication_scheme[:select]}
		 					from projects 
							#{@duplication_scheme[:join]}
				 			#{@duplication_scheme[:group]}
				 			) p
				 			
		 				LEFT OUTER JOIN sectors on p.sector_id = sectors.id
		 				LEFT OUTER JOIN oda_likes on p.oda_like_id = oda_likes.id
		 				LEFT OUTER JOIN flow_types on p.flow_type_id = flow_types.id
		 				LEFT OUTER JOIN verifieds on p.verified_id = verifieds.id

			 			INNER JOIN countries donors on p.donor_id = donors.id 
			 			LEFT OUTER JOIN (select sum(usd_current) as sum_usd_current, sum(usd_defl) as sum_usd_defl, project_id from transactions group by project_id) as t on p.id = t.project_id
			 		where 
			 		#{@filters.join(' and ')}
					group by #{@fields_to_get.select{|f| Rails.env.production? ? f[:internal] : f[:group] }.map{|f| Rails.env.production? ? f[:internal] : f[:group]}.join(', ')} "
					
					# That little nonsense is because you group by recipient_iso2 in SQLite but recipients.name in PSQL
			@data = ActiveRecord::Base.connection.execute(sql)

			@errors = []
			if @wdi
				@data = @data.map do |d|
					if d["year"] && d["recipient_iso3"] && d["recipient_iso3"].length == 3
						@wdi.each do |wdi_code|
							request_url = "http://api.worldbank.org/countries/#{d["recipient_iso3"]}/indicators/#{wdi_code}?format=json&date=#{d["year"]}"
							wdi_response_string = open(request_url){|io| io.read} 
							response_feed = ActiveSupport::JSON.decode(wdi_response_string)
							d[wdi_code] = response_feed[1][0]["value"] 
						end
					else 
						@errors.push(d)
					end
					d
				end
			end
			
				
			
			
			@column_names = @fields_to_get.map{|f| f[:external]} + ["usd_2009", "usd_current", "count"] + @wdi
		  
		  respond_to do |format|
		    # default: render json
		    format.json { render json: @data.as_json(only: @column_names)}
		    # if asking for CSV, send an on-the-fly CSV
		    format.csv { send_data data_to_csv, filename: "AidData_China_Aggregates_#{Time.now.strftime("%y-%m-%d-%H:%M:%S.%L")}.csv"}
		  end
		  
		else	
			render json: params
	  end  		
	
	end
	
	private
		def data_to_csv
		 CSV.generate do |csv|
				csv << @column_names
				@data.each do |datum|
					csv << datum.values_at(*@column_names)
				end
			end
		end
end
