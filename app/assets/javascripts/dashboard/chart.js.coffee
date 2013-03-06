@App = @App || {}


App.plot_bars = (options) ->

	options = options || {}
	options.bar_data = options.bar_data || App.bar_data
	if options.this_x_axis
		console.log "recieved this_x_axis:", options.this_x_axis
		this_x_axis = options.this_x_axis 
	else 
		console.log "didn't receive this_x_axis"
		this_x_axis = App.current_x_axis ||  "year"
		make_x_axis(this_x_axis)


	console.log "Plot bars ", this_x_axis

	bars = App.svg.selectAll(".bar")
		.data(App.bar_data)
		
	bars.enter().append('rect')
		.attr("class", "bar")

	bars.exit().remove()

	rescale_when_done = false

	bars.transition()
			.delay((d,i) -> i*20 )
			.attr("x", (d,i) -> "#{ App.config.vis_padding_left + App.x_scale(d.key) }px")
			.attr("y", (d) -> App.config.vis_padding_top + App.amount_scale(d.value) + "px" )
			.attr("width", App.x_width )
			.attr("height", (d) -> 
				max_h = (App.config.vis_height - App.config.vis_padding_top - App.config.vis_padding_bottom)
				h = max_h - App.amount_scale(d.value) 
				if h > max_h
					rescale_when_done = true
				h + "px" )
			.style("fill", (d) -> App.amount_color_scale(d.value) )

	if rescale_when_done
		App.scale_y_to_fit(App.bar_data)
		bars.transition()
			.delay((d,i) -> ((i*20) + 250))
			.attr("y", (d) -> App.config.vis_padding_top + App.amount_scale(d.value) + "px" )
			.attr("height", (d) -> 
				max_h = (App.config.vis_height - App.config.vis_padding_top - App.config.vis_padding_bottom)
				h = max_h - App.amount_scale(d.value) 
				if h > max_h
					rescale_when_done = true
				h + "px" )
			.style("fill", (d) -> App.amount_color_scale(d.value) )

	bars
		.on('mouseover', show_data)
		.on('mouseout', hide_data)


show_data = (d,i) ->
	$(this).attr("opacity", ".6")
	update_now_showing(d)

hide_data = (d, i) ->
	$(this).attr('opacity', '1')



update_now_showing = (d) ->
	# console.log(d)
	filters = App.get_all_filters()
	now_showing = {}

	filters.forEach((filter) ->
		values = filter.values
		key = filter.key
		if values.length > 0 && key != App.current_x_axis
			# console.log key
			if key == "year"
				if values.length == 1
					now_showing["year"] = "In #{values[0]},"
				else
					now_showing["year"] = " In #{values.length} years,"
			else if key == "recipient"
				if values.length == 1
					now_showing['recipient'] = "to #{values[0]}"
				else 
					now_showing["recipient"] = "to #{values.length} countries"
			else if key == "sector"
				now_showing["sector"] = " in #{values.length} sectors"
			else if key == "flow_class"
				if values.length == 1 
					now_showing["flow_class"] = "from #{values[0]}"
				else
					now_showing["flow_class"] = "by #{values.length} modalities"

		else if key == App.current_x_axis
			if key == "year"
				now_showing["year"] = " In #{d.key},"
			else if key == "recipient"
				now_showing["recipient"] = "to #{d.key}"
			else if key == "sector"
				now_showing["sector"] = " for #{d.key}"
			else if key == "flow_class"
				now_showing["flow_class"] = "by #{d.key}"	
	)

	# console.log "now_showing", now_showing

	now_showing_string = "#{now_showing['year'] || "" }" +
		" $#{d3.format(',')(d.value)} went " +
		" #{now_showing['flow_class'] || 'by all modalities' }" +
		" #{now_showing['recipient'] || 'to all countries' }" +
		"#{now_showing['sector'] || '' }." 
		

	$('#detail').text(now_showing_string)

App.draw_from_filters = (options_for_plot_bars) ->
	# console.log "Draw from filters, x-axis:", App.current_x_axis
	
	filters = App.get_all_filters()

	new_data = App.projects.where((table, row) ->
		passes = true
		filters.forEach((filter) ->
			if filter.values.length > 0 && !(table.get(filter.key, row) in filter.values)
				passes = false
				)	
		# console.log passes
		passes
	)

	if d3.sum(filters.map((f) -> f.values.length )) == 0
		App.scale_y_to_fit(App.bar_data)

	App.make_sums(new_data, App.current_x_axis)
	App.plot_bars(options_for_plot_bars)

	$('#detail').html("<i>Mouseover for detail</i>")

App.make_with_new_x_axis = (new_axis) ->
	console.log 'requesting new with x-axis:', new_axis
	make_x_axis(new_axis)
	App.draw_from_filters()


make_x_axis = (column) ->
	
	$('.x_axis_controller').removeClass("current_x_axis")
	$("##{column}_filters .x_axis_controller").addClass('current_x_axis')

	domain = App.get_filter_values(column)
	
	if domain.length == 0
		# $("##{column}_filters .inactive").toggleClass("inactive").toggleClass("active")
		domain = $(".filters tr.#{column}")
			.children('.value').map((i,d) -> d.innerHTML.trim() )
			.get()

	console.log "Make x axis", column, domain

	App.current_x_axis = column

	App._x_scale_calculator = d3.scale.ordinal()
			.domain(domain)
			.rangeBands([0,App.config.vis_width - App.config.vis_padding_left], .1)

	App.x_scale = (d) -> 
		App._x_scale_calculator(d)

	App.x_width = (700 * .9)/domain.length

	App.x_axis = d3.svg.axis()
		.scale(App._x_scale_calculator)
		.orient('bottom')

	this_x_axis = App.svg.selectAll('.x_axis')
		.data([column])

	this_x_axis
		.enter().append('g')
		.attr('class', 'x_axis')
		.attr('transform', "translate(#{App.config.vis_padding_left}, #{App.config.vis_height - App.config.vis_padding_bottom})")

	this_x_axis	
		.call(App.x_axis)
		.selectAll("text")
			.style("text-anchor", "end")
			.attr("dx", "-.8em")
			.attr("dy", ".15em")
			.attr("transform", (d) -> "rotate(-65)"  );