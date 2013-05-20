module AggregatesHelper	


    ICONS = {

        "doc" => "data:image/gif;base64,R0lGODlhEAAQANUgANvh8gZCm0RrvGCAylhwppOr5rnI7XmT1oCe5jJVmT1otmeK1TVesgg4ia672IOc2ipit4uk3Vd90E52y3eKnGd+syg+bfDy+oml6U1qpwlLsgU2goSEhMbGxgAAAP///////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAACAALAAAAAAQABAAAAaIQJCQQywahUgQ58NsMjkeYaGAQRwWkokA8oSCCk6nhukpexCGxwCwJkQ0nfincwaoAQJAhjKezz0HHwcCDgkRCQYBHX50Cx8VAgQbDBYfioweEh8EiBsbDh8NcYt0Ex+TFxsKTBtOdKthrKN/EBq2AbgNnq5RQ2GjpL1KsbxIHMDIccJQZs3NQQA7",

        "xls" => "data:image/gif;base64,R0lGODlhEAAQAMQfADRMGDhsIDRiFGuuZVWWRUiLOJXDkEaELDt3HI+8ij19I2SnXTNZFV6OVs3bzP79+trl2nOkb6CynpuvmoaohG+abOTr5FygVTJsDQoKCoSEhP7+/sbGxgAAAP///////yH5BAEAAB8ALAAAAAAQABAAAAWL4CdqZGmK6Kd57MOyWicOw3IRRHEoCPzIg41wKMSwMh3kwLAgbByNywTDqXo4mYXFMDhELgWI8XrtXJ6GiyLA2QiqnGvGmbikAxWIgBXndAoJCAECCQUBEgxwcgdEFIMNAC9lCkREkWR+CBibAgwMAKB9cigrcH1WfqSSq2Wkpq9VMiMdSbS0GUhIIQA7",

        "ppt" => "data:image/gif;base64,R0lGODlhEAAQANUgAO+TaZQ4LY8zJpE6M/CXXdd/XsdzV8VoTYcsJ9uDYvCkb//8+X0iGvCabPDJmfC6hlYMD9F3WMtULfbWxvJ/S/z07rA5L51dSP7n27BdQ6pJN7xdRYSEhMbGxgAAAP///////wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAACAALAAAAAAQABAAAAaTQJCQQywahUgQ58NsMonCRKJQiBgOh83m+eGAEh9MZjC4TD7bj2ftKWA0lQVkgJhsOvhPp52JyyUNGRpOexECFBQAgAoBGngdeh4GAw4ODwAACgIBhB4HGQSWDQAEGQKPkQdvBAqkFhgInVsYBgEBBhgfDKh7WoIaAQIIDAydSEt6eo+Qe8dOz5HHy9N4Hsds2NlBADs=",

        "graphic" => "data:image/gif;base64,R0lGODlhEAAQALMPAPHv3hZpyg8wX6+sovzSSdKsOc/FnZp4PPOlqNm1SrUhKMbGxoSEhAAAAP///////yH5BAEAAA8ALAAAAAAQABAAAARa8ElGq5X4Mcc7Z02meR4VYhvJNew5qt3ipg5yGJ6MOkug/IBEwaCbBI4+BWE5nCEFgsSSUDg4j4JBYVqdAQJQhlZ4sO48gHIZdM4ZBvAZLDZb2O/4oqbF70cAADs=",

        "txt" => "data:image/gif;base64,R0lGODlhEAAQAKIAAIWFhYSEhAAAAMbGxv///////wAAAAAAACH5BAEAAAUALAAAAAAQABAAAAM8WBrcrrAEQisNIkoyuicBkEGTVQnouHnswKmlWQ0w13YvKVu0fuO9xW5W+7mCm2FOaFwmh8iA0QNLWa8JADs=",

        "zip" => "data:image/gif;base64,R0lGODlhEAAQALMIAOHhF66srE9PTy0tLcbGxoSEhAAAAP///////wAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEAAAgALAAAAAAQABAAAARVEMlCq5UYlcM7L0ameR4VYhsXDOwAGucYCEJgF8NBxJsACJbcDnXwAY5AIa94ROJ0S5o0CSUeBras0npt5aoTErAzDB9eaPCI5ClrCPC43P2C2e+GCAA7",

        "sound" => "data:image/gif;base64,R0lGODlhEAAQALMPAG2Q10RipPHy8ipXpzBAeWN0qK2xvnqEmUpei5qhtIGjxsbGxoSEhAAAAP///////yH5BAEAAA8ALAAAAAAQABAAAARY8ElGq5X4Mcc7Z02meR4VYpu3FEXjniPHFgDBLXDqIEFQILdcBygQAB041NBRPCYnS4HBhhQ6po4DYCCoKrXcxEDRfY7ECpIXylSvY+43Y0Gv282gl14fAQA7",

        "pdf" => "data:image/gif;base64,R0lGODlhEAAQALMPAPsICf+0tP+KiqcBAtygof/q6vxhYf/Y2IsBA+5UVfYSFcbGxoSEhAAAAP///////yH5BAEAAA8ALAAAAAAQABAAAARm8ElGq5X4Mcc7Z41EJCSpJIrygY+ZvgDCNXSDvikADN7SKIigcEDshSaeRMCI2XAKBkGh42t2BIGDIXuoIjlbgcCgMBiOGk5gO3UUAgT0Zn3wcLwag9J+l5vbdngMC4SFhoI1iYoRADs=",

        "html" => "data:image/gif;base64,R0lGODlhEAAQAMQfAFOrFdz4lUWOs1JTsCNzHK/Xmerp+oSkyE1w8y9ZkdLU60NS9DA44xpZP46O03V50jSKV4HPOK7lYRc0aTuHHzQ9yRgkkbHxUE5b1qGn4k+pZ4SEhMbGxgAAAP///////yH5BAEAAB8ALAAAAAAQABAAAAWO4CduZGmK6Ld5bMtuXap6XG17ZIwqDvJkhlZnGDMcOIFLJIGxcWgdY2B6ATQWGEWL08loChIlIbFgPGrQB4RAiVCu5cG2gxFAGhQKJMFgWNBcDwiDBBESAHxyLFwZGIMNAIcNFg6AUQ4VCwmQFBMDQYs6mBUTDZ5OUCIGDgMWCQ9aLlwoG062NToqRLu8IQA7",

    }

    SPREADSHEET_ICON = ICONS["xls"]
    

	VALUE_DELIMITER = "*" 
	
	VALID_FIELDS = [
			{external: "donor", name: "Donor", internal: "donors.iso3", group: "donors.iso3", sorter: "donors.iso3 asc" },
			{external: "status", name: "Status", group: "statuses.name", internal: "(case when statuses.name is null then 'Unset' else statuses.name end)", sorter: "status asc"},
			{external: "intent", name: "Intent", group: "intents.name", internal: "(case when intents.name is null then 'Unset' else intents.name end)", sorter: "intent asc"},
			{external: "crs_sector_name", name: "Sector", internal: "(case when crs_sectors.name is null then 'Unset' else crs_sectors.name end)", group: "crs_sectors.name", sorter: "crs_sector_name asc"},
			{external: "flow_class", name: "Flow Class", group: "oda_likes.name", internal: "(case when oda_likes.name is null then 'Unset' else oda_likes.name end) ", sorter: "flow_class asc"},
			{external: "recipient_iso2",  name: "Recipient ISO2", group: "recipient_iso2", internal: "recipient_iso2", sorter: "recipient_iso2 asc"},
			{external: "recipient_iso3",   name: "Recipient ISO3", group: "recipient_iso3", internal: "recipient_iso3", sorter: "recipient_iso3 asc"},			
			{external: "recipient_name", name: "Recipient Name",   group: "recipient_name", internal: "recipient_name", sorter: "recipient_name asc"},
			{external: "year",  name: "Year", internal: "year", group: "year", sorter: "year desc"}
			# active 
		]
		
	
	WHERE_FILTERS = [
	    	{sym: :recipient_iso2, name: "Recipient ISO2", options:  Proc.new { Country.all.map(&:iso2) } , internal_filter: "recipient_iso2"},
	    	{sym: :recipient_name, name: "Recipient Name", options:   Proc.new { Country.all.select{ |c| c.projects_as_recipient.count > 0 }.map(&:name) }.call, internal_filter: "recipient_name"},
	    	{sym: :crs_sector_name, name: "CRS Sector Name", options:  Proc.new { CrsSector.all.map(&:name) }.call , internal_filter: "crs_sectors.name"},
	    	{sym: :intent_name, name: "Intent", options:  Proc.new { Intent.all.map(&:name) }.call , internal_filter: "intents.name"},
	    	{search_constant_sym: :verified_name, sym: :verified, name: "Verified Status", options:  Proc.new { Verified.all.map(&:name) }.call , internal_filter: "verifieds.name"},
	    	{search_constant_sym: :flow_type_name, sym: :flow_type, name: "Flow Type", options:  Proc.new { FlowType.all.map(&:name) }.call, internal_filter: "flow_types.name"},
	    	{search_constant_sym: :oda_like_name, sym: :flow_class, name: "Flow Class", options: Proc.new { OdaLike.all.map(&:name) }.call, internal_filter: "oda_likes.name" },
	    	{search_constant_sym: :status_name, sym: :status, name: "Status", options:  Proc.new { Status.all.map(&:name) }.call, internal_filter: "statuses.name" },
	    	{sym: :year, name: "Year", options: ("2000".."2011").to_a.reverse! , internal_filter: "year" },
	    	#{sym: :donor_name, name: "Donor Name", options:  Proc.new { Country.all.map(&:name) } , internal_filter: "donor.name"},
	    ]
	

DUPLICATION_HANDLERS = [
	# MERGE --> If a project has multiple recipients, call it "Africa, Regional"
	{external: "merge", name: "Merge",
	 note: "If a project has multiple recipients, call it 'Africa, Regional'",
			select: '"geo.*"', 
			group: "", 
			join: "INNER JOIN (select project_id," +
					"(case when count(recipients.id) > 1 then 'Africa, regional' else max(recipients.name) end) as recipient_name," +
					"(case when count(recipients.id) > 1 then 'XR' else max(recipients.iso2) end) as recipient_iso2, "+
					"(case when count(recipients.id) > 1 then 'Africa, regional' else max(recipients.iso3) end) as recipient_iso3,"+
					"count(*) as g_count from geopoliticals g "+
					"INNER JOIN countries recipients on g.recipient_id = recipients.id group by g.project_id )  geo on projects.id = geo.project_id ",
			amounts: "round(cast(sum(sum_usd_defl) as numeric),2) as usd_2009, round(cast(sum(sum_usd_current) as numeric),2) as usd_current"
			}, 
					
	# PERCENT THEN MERGE --> If a project has multiple recipients and percentages add up to 100, 
	#															Then divide along those percentages
	#												 Else call it "Africa, Regional"
	{external: "percent_then_merge", name: "Percent Then Merge",
	 note: 'If a project has multiple recipients and percentages add up to 100, then divide along those percentages, else call it "Africa, Regional"',
			select: '@recipient_field_names.map { |fn| 
				"(case 
				when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND 
				(select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) != 100) then 
				#{africa_regional_iso2(fn)} 

				else recipients.#{fn} end ) as recipient_#{fn}"}.join(", ") + 
				
				", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND 
					(select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 
				else 1.0/(select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) end) as multiplier"',
			group: "", 
			join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
						"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
			amounts: "round(cast(sum(sum_usd_defl*p.multiplier) as numeric), 2) as usd_2009, 
					round(cast(sum(sum_usd_current*p.multiplier) as numeric), 2) as usd_current"
			 },
	 
	# PERCENT THEN SHARE --> If a project has multiple recipients and percentages add up to 100, 
	#															Then divide along those percentages
	#												 Else share it equally among recipients
	{external: "percent_then_share", name: "Percent Then Share",
	 note: "If a project has multiple recipients and percentages add up to 100, then divide along those percentages, else share it equally among recipients",
			select: '@recipient_field_names.map { |fn| 
					"recipients.#{fn} as recipient_#{fn}"}.join(", ") + 
					", (case when ((select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) > 1 AND
					 (select sum(percent) from geopoliticals g3 where g3.project_id=geo.project_id group by project_id) = 100) then geo.percent/100.0 else 1.0/(select count(*) from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) end) as multiplier"',
			group: "",
			join:"LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
						"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
			amounts: "round(cast(sum(sum_usd_defl*p.multiplier) as numeric), 2) as usd_2009, round(cast(sum(sum_usd_current*p.multiplier) as numeric),2) as usd_current"
			 },
	
	# SHARE --> If a project has multiple recipients, share the amount equally among recipients
	{external: "share", name: "Share",
	 note: "If a project has multiple recipients, share the amount equally among recipients",
			select: '@recipient_field_names.map { |fn| 
				"recipients.#{fn} as recipient_#{fn}"}.join(", ") +
				",(select count(*)*1.0 from geopoliticals g2 where g2.project_id=geo.project_id group by project_id) as recipients_count"' ,
			group: "", 
			join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
						"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
			amounts: "round(cast(sum(sum_usd_defl/p.recipients_count) as numeric),2) as usd_2009,
			          round(cast(sum(sum_usd_current/p.recipients_count) as numeric),2) as usd_current"
			},
			
	# DUPLICATE --> If a project has multiple recipients, allocate the full amount to each recipient (DOUBLE-COUNTING)
	{external: "duplicate", name: "Duplicate",
		note: "If a project has multiple recipients, allocate the full amount to each recipient (DOUBLE-COUNTING)",
			select: '@recipient_field_names.map { |fn| "recipients.#{fn} as recipient_#{fn}"}.join(", ") ',
			group: "",
			join: "LEFT OUTER JOIN geopoliticals geo on projects.id = geo.project_id " +
						"INNER JOIN countries recipients on geo.recipient_id=recipients.id",
			amounts: "round(cast(sum(sum_usd_defl) as numeric), 2) as usd_2009, round(cast(sum(sum_usd_current) as numeric),2) as usd_current"
			}
]
			
			WDI = [
				{ code: "DT.ODA.ALLD.CD", 
					name: "Net official development assistance and official aid received (current US$)", 
					note: "Official Aid (USD-current)"
				},
				{ code: "DT.ODA.ODAT.PC.ZS",
					name: "Net ODA received per capita (current US$)",
					note: "ODA per capita (USD-current)"
				},
				{ code: "DT.ODA.ODAT.GN.ZS",
					name: "Net ODA received (% of GNI)",
					note: "ODA/GNI"
				},
				{ code: "SH.DYN.MORT",
					name: "Mortality rate, under-5 (per 1,000 live births)",
					note: "Under-5 mortality rate, per 1000"
				},
				{ code: "EN.ATM.CO2E.KT",
					name: "CO2 emissions (kilotons)",
					note: "CO2 (kt)"
				}
			]
end