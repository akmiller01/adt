((function(){var a,b,c,d;this.App=this.App||{},App.initialized=!1,App.respond_to_html_changes=!1,App.initialize=function(b){return console.log("pulling from csv"),window.d3.csv(b,function(b){var e;return console.log("processing CSV"),App.config.data.preprocessing_function&&(b=App.config.data.preprocessing_function(b)),App.projects=dv.table(),App.config.data.columns.forEach(function(a){return App.projects.addColumn(a.name,a.values_function(b),a.dv_type)}),$("#waiting").remove(),App.svg=d3.select("#vis").append("svg").attr("height",App.config.vis_height).attr("width",App.config.vis_width),App.values=function(){var a,b,c,d;c=App.config.data.columns,d=[];for(a=0,b=c.length;a<b;a++)e=c[a],e.interface_type==="value"&&d.push(e.name);return d}(),App.filters=function(){var a,b,c,d;c=App.config.data.columns,d=[];for(a=0,b=c.length;a<b;a++)e=c[a],e.interface_type==="filter"&&d.push(e.name);return d}(),App.other_attributes=function(){var a,b,c,d;c=App.config.data.columns,d=[];for(a=0,b=c.length;a<b;a++)e=c[a],e.interface_type==="none"&&d.push(e.name);return d}(),App.attributes=function(){var a,b,c,d;c=App.config.data.columns,d=[];for(a=0,b=c.length;a<b;a++)e=c[a],d.push(e.name);return d}(),c(App.filters),d(App.values),$("#filter_container .accordion-body").addClass("in"),$(".filter_box").on("keyup",a),App.initialized=!0,console.log("finished loading"),App.start_url_observer()})},d=function(a){return $("#value_container").append("<b>Measure: </b>",a.map(function(a){return"<span class='btn controller y_axis_controller "+a+"' data-column-name='"+a+"'\t\t\t\t\t\t\t\t\tonclick='App.current_y_axis(\""+a+"\")'>\t\t\t\t\t\t\t\t\t"+a+"\t\t\t\t\t\t\t\t</span>"}).join(" "))},c=function(a){var c,d,e,f,g,h;e=0,c=0,h=[];for(f=0,g=a.length;f<g;f++)d=a[f],e%4===0&&(c+=1,$("#filter_container").append("\t\t\t\t<div class='filter_subcontainer_"+c+" row-fluid'>\t\t\t\t</div>\t\t\t\t")),b(d,".filter_subcontainer_"+c),h.push(e+=1);return h},b=function(a,b,c,d){var e;return c==null&&(c="3"),d==null&&(d="inactive"),console.log("make filter selector for ",a,"in",b),$(b).append("<div class='accordion-group span"+c+"'>\t\t\t\t<div class='accordion-heading'>\t\t\t\t\t<span class='accordion-toggle' data-toggle='collapse' data-parent='#filter_container' >\t\t\t\t\t\tFilter by "+a+":\t\t\t\t\t</span>\t\t\t\t</div> \t\t\t\t<div id='collapse_"+a+"' class='accordion-body collapse'>\t\t\t\t\t<div class='accordion-inner' id='"+a+"_accordion'>\t\t\t\t\t\t<div class='controls'>\t\t\t\t\t\t\t</div>\t\t\t\t\t\t<div class='filters'>\t\t\t\t\t\t</div>\t\t\t\t\t</div>\t\t\t\t</div>\t\t\t</div>"),e="#"+a+"_accordion",$(""+e+" .controls").append("\t\t<div class='row-fluid'>\t\t\t<a class='controller x_axis_controller btn span12' data-column-name='"+a+"' onclick='App.current_x_axis(\""+a+"\")'>\t\t\t\t\tSet this on X-axis\t\t\t</a>\t\t</div>\t\t<div class='row-fluid'>\t\t\t<span class='controller btn deactivator span6' onclick='App.set_all_filters(\"inactive\", \""+a+"\")'>\t\t\t\tDeselect All\t\t\t</span>\t\t\t<span class='controller btn activator span6' onclick='App.set_all_filters(\"active\", \""+a+"\", true)'>\t\t\t\tSelect Visible \t\t\t</span>\t\t</div>\t\t<div class='row-fluid'>\t\t\t<span> \t\t\t\t<input type='text' class='filter_box span12' value='Type to filter...' onfocus='this.value=\"\"'>\t\t\t</span>"),App.projects[a].lut.forEach(function(b,c){return $(""+e+" .filters").append("<span \t\t\t\tdata-searcher='"+b.toLowerCase()+"' \t\t\t\tdata-value='"+b+"' \t\t\t\tdata-column='"+a+"'\t\t\t\tclass='"+a+" controller "+d+" value'\t\t\t\tonclick='App.toggle_filter(this)'\t\t\t>\t\t\t\t"+b+"\t\t\t</span>")})},a=function(a){var b,c,d;return b=(d=a.target.value)!=null?d.toLowerCase():void 0,c=$(a.target).closest(".accordion-group").find(".value"),b.length>0?c.each(function(a,c){return b===$(c).attr("data-searcher").substr(0,b.length)?$(c).css("display","inherit"):$(c).css("display","none")}):c.css("display","inherit")},App.sort_orders=[{name:"a_to_z",text:"A &rarr; Z","function":function(a){return a.key}},{name:"big_to_small",text:"Max &rarr; Min","function":function(a){return-a.value}}]})).call(this);