((function(){var a,b,c,d,e,f,g,h,i,j,k;c=function(){var a,b;return d3.selectAll(".fuzz").transition().duration(500).attr("filter","url(#blur)"),b=window.vis.append("svg:g").attr("id","overlay-wrapper").attr("class","overlay"),a=b.append("svg:rect").attr("id","grayBox").attr("class","overlay").attr("height",window.vis_config.h).attr("width",window.vis_config.w).style("fill","black").style("opacity","0").on("click",k),a.transition().duration(600).style("opacity",".7"),b},k=function(){return d3.selectAll(".overlay").transition("opacity",0).delay(10).duration(100).remove(),d3.selectAll(".fuzz").transition().duration(1e3).attr("filter","")},d=function(a){var b;return b={iso2:a.id,name:$(a).attr("name")}},f=function(a,b){var c,d,e,f;return d=window.vis_config.h,f=window.vis_config.w,e=window.vis_config.label_green,c=a.append("svg:g").attr("id","country_header").append("svg:foreignObject").attr("x",120).attr("y",20).attr("height",d/6).attr("width",f/2.1).append("xhtml:body"),c.attr("height",d/6).attr("width",f/2.1).style("padding-top","10px").style("background-color","transparent").style("opacity","1").style("color",e.brighter()).style("font-size",50).style("font-family","Georgia").style("font-weight","bold").html("<div id='country_header_body' style='line-height:40px;font-size:40px;opacity:1; "+("height:"+d/6+"; width:"+f/2.1+"'>\t\t\t<h1 style='color:"+e.brighter()+";border-color:"+e.brighter()+"' class='page-header country-header'>\t\t\t\t"+b.name+"\t\t\t\t</h1>\t\t\t\t</div>"))},g=function(a,b){var c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r;j=d3.layout.pie().sort(d3.ascending),g=window.vis_config.label_green,n=40,c=d3.svg.arc().outerRadius(n),i=Math.round(window.map_data.filter(function(a){return a.key===b.iso2})[0].values.value/window.total_amount_in_view*1e3)/10,l=[100-i,i],o=function(a){var b;return a.innerRadius=0,b=d3.interpolate({startAngle:0,endAngle:0},a),function(a){return c(b(a))}},k=a.append("svg:g").data([l]).attr("id","pie_chart").attr("width",n*2).attr("height",n*2).attr("transform","translate(20,20)"),d=k.selectAll("g.arc").data(j).enter().append("g").attr("class","arc").attr("transform","translate("+n+","+n+")"),h=d.append("path").attr("fill",function(a,b){return b===1?g.brighter():"#fff"}),h.transition().duration(1e3).attrTween("d",o),m=[{text:""+i+"%",size:17},{text:"of flows",size:12},{text:"on map.",size:12}],r=[];for(e=p=0,q=m.length;p<q;e=++p)f=m[e],r.push(k.append("text").attr("y",n+2+e*12).attr("x",n).attr("text-anchor","middle").attr("fill",g.darker()).style("font-weight","bold").style("font-size",f.size).text(f.text));return r},h=function(a,b){var c,d,e,f,g,h,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D;return window.vis_config.years.length===1&&(window.vis_config.years=[window.vis_config.years[0]-1,window.vis_config.years[0],Number(window.vis_config.years[0])+1]),D=window.vis_config.years,w=b.data.map(function(a){return a.crs_sector_name}).getUnique(),x=[],w.forEach(function(a){var c;return c=[],D.forEach(function(d){var e,f;return f=b.data.filter(function(b){return Number(b.year)===d&&b.crs_sector_name===a}),e={x:d,y:d3.sum(f,function(a){return a.usd_2009})},c.push(e)}),x.push(c)}),C=d3.layout.stack()(x),p=d3.nest().key(function(a){return a.crs_sector_name}).rollup(function(a){return{value:d3.sum(a,function(a){return a.usd_2009}),count:d3.sum(a,function(a){return a.count})}}).entries(b.data),c=[],C[0].forEach(function(a,b){var d;return d=0,C.forEach(function(a){return d+=a[b].y}),c.push(d)}),d=Math.max(Math.round(d3.max(c)/5e6)*5e6,1e7),f=window.vis_config.h,z=window.vis_config.w,s=.4*z,t=.4*z,v=d3.scale.pow().domain([0,d]).range([s,0]),u=d3.scale.linear().domain([d3.min(D),d3.max(D)]).range([0,t]),j=1/16*f,n=f-1/16*f,m=.5625*z,k=d3.scale.linear().domain([0,p.length]).range([j,n]),l=d3.min([k(1)-k(0),35]),q=d3.svg.area().x(function(a,b){return u(a.x)}).y0(function(a){return v(a.y0)}).y1(function(a){return v(a.y+a.y0)}).interpolate("monotone"),o=d3.svg.area().x(function(a){return u(a.x)}).y0(s).y1(s).interpolate("monotone"),g=a.append("svg:g").attr("id","headers").append("svg:foreignObject").attr("height",l*(p.length+2)+10).attr("width",.4375*z).attr("x",m-20).attr("y",j+45).append("xhtml:body").attr("id","sectors_body").style("padding","5px").style("background-color","hsla(360, 0%, 100%, 0.95)"),h="\t\t<table style='margin:3px;font-size:"+window.vis_config.bigger_font_size+"px' class='table table-hover'>\t\t\t<thead>\t\t\t\t<tr>\t\t\t\t\t<th>Sector</th>\t\t\t\t\t<th>Amount</th>\t\t\t\t\t<th>Projects</th>\t\t\t\t</tr>\t\t\t</thead>\t\t\t<tbody>",y="padding:2px;line-height:14px;",p.forEach(function(a){var c;return c="/projects?active_string=Active"+(current_scope.name!=="All Projects"?"&scope_names[]="+current_scope.name:"")+("&country_name="+b.name+"&crs_sector_name="+a.key),h+="\t\t\t<tr>\t\t\t\t<td style='"+y+"'>\t\t\t\t\t<a href='"+c+"'>\t\t\t\t\t<strong style='color:"+window.vis_config.c_sector(a.key)+"'>"+a.key+"<strong>\t\t\t\t\t</a>\t\t\t\t</td>\t\t\t\t<td style='"+y+"'>\t\t\t\t\t<a href='"+c+"'>\t\t\t\t\t\t$"+window.vis_config.nicemoney(Math.round(a.values.value))+"\t\t\t\t\t</a>\t\t\t\t</td>\t\t\t\t<td style='"+y+"'>\t\t\t\t\t<a href='"+c+"'>\t\t\t\t\t\t"+a.values.count+" \t\t\t\t\t</a>\t\t\t\t</td>\t\t\t</tr>"}),h+="</tbody></table>",g.html(h),ApplySortability(),e=a.append("svg:g").attr("id","area_chart").attr("transform","translate("+.125*z+","+.2*f+")"),A=d3.svg.axis().scale(u).orient("bottom").tickFormat(d3.format("f")).tickValues(D),e.append("svg:g").attr("class","axis").call(A).style("fill","#ccc").attr("transform","translate(0,"+(s+2)+")").attr("opacity",0),B=d3.svg.axis().scale(v).orient("left").tickFormat(function(a){return"$"+window.vis_config.nicemoneyaxis(a)}),e.append("svg:g").attr("class","axis").call(B).style("fill","#ccc").attr("opacity",0),e.selectAll(".axis").transition().delay(function(a,b){return 50*b}).attr("opacity",1).attr("font-size",window.vis_config.smaller_font_size),r=e.selectAll(".sector_area").data(C).enter().append("path").attr("class","sector_area overlay").attr("id",function(a,b){return"sectorPath"+b}).attr("fill",function(a,b){return window.vis_config.c_sector(p[b].key)}).attr("d",o).transition().duration(600).attr("d",q),i(a,b,p,u,v,e)},i=function(a,c,d,e,f,g){var h,i,k,l,m,n,o,p,q,r;return r=window.vis_config.w,i=window.vis_config.h,n=20,o=.725*i,l=.25*i,q=.5*r,k=a.append("svg:g").attr("id","top_projects").attr("transform","translate("+n+", "+o+")").append("svg:foreignObject").attr("id","top_projects_body").attr("height",.05*i).attr("width",q).style("background-color","hsla(319, 0%, 100%, 0.7)").style("margin","0 0 0 0").style("padding","5px 5px 5px 5px").append("xhtml:body").attr("height",.05*i).style("background-color","transparent").style("color","black").html("<p><b>Loading top projects...</b></p>"),p="/projects.json?max=5"+(current_scope.name!=="All Projects"?"&scope_names[]="+current_scope.name:"")+"&active_string=Active"+"&order_by=usd_2009&dir=desc"+"&recipient_iso2="+c.iso2,m=5,h=d3.scale.linear().domain([0,(m-1)/2,m-1]).range(["#2A5C0B","#55760f","#808f12"]),$.get(p,function(a){return j(a,d,h,e,f,g),b(c,a,"top_projects_body",l,h)},"json")},b=function(a,b,c,d,e){var f,g,h;return f="<div style='text-align:left;font-size:"+window.vis_config.medium_font_size+";'>"+("<p><b>Top projects in "+a.name+":</b></p><ul>"),b.forEach(function(a,b){var c;return f+="<li style='color:"+e(b)+"'>"+("<span style='color:black'><a href='/projects/"+a.id+"'>"+a.title+"</a> ("+((c=a.year)!=null?c:"<i>no year</i>")+"),")+(" $"+window.vis_config.nicemoney(a.usd_2009)+"</span></li>")}),f+="</ul>\t\t<p><a href='/projects?country_name="+a.name+"&active_string=Active'>\t\t\tSee all projects in "+a.name+" &rarr;\t\t\t</a>\t\t\t</p>\t\t</div>",g=d3.select("#"+c),g.transition().attr("height",0),h=$("#"+c),h.children().remove(),h.append("<xhtml:body>"+f+"</xhtml:body>"),g.transition().attr("height",d)},j=function(a,b,c,d,e,f){var g,h,i;return i=b.map(function(a){return a.key}),g=function(a){var b;return b=yearSectorStack[i.indexOf(a.crs_sector_name)][a.year-d3.min(this.years)],b?b.y0+b.y:0},h=f.selectAll(".project_point").data(a).enter().append("svg:circle"),h.attr("cx",function(a){return d(a.year)}).attr("cy",function(a){return e(a.usd_2009)}).attr("r","0px").attr("fill",function(a,b){return c(b)}).attr("stroke","black").attr("stroke-weight",1).transition().duration(500).delay(function(a,b){return b*200}).attr("r","3px"),h.append("title").text(function(a){return a.title})},e=function(b,c){var d,e,f,g,h;return g=window.vis_config.w,e=window.vis_config.h,f={},f.height=1/8*g,f.width=.35*g,f.offset_y=.75*e,f.offset_x=g-f.width-50,f.text_margin=33,f.selection=b.append("svg:g").attr("id","line_chart").attr("transform","translate("+f.offset_x+", "+f.offset_y+")"),f.selection.append("svg:rect").attr("id","line_chart_background").attr("x",-0.025*g).attr("y",-0.025*e).attr("height",.2*g).attr("width",f.width+50).attr("stroke","transparent").style("fill","hsla(0, 0%, 10%, 0.5)"),h=function(a,b){return encodeURIComponent("http://api.worldbank.org/countries/"+a+"/indicators/"+b+"?per_page=50&date=1999:2012&format=json")},window.worldbank_gni_url=h(c.iso2,"NY.GNP.ATLS.CD"),window.worldbank_dacoda_url=h(c.iso2,"DC.DAC.TOTL.CD"),window.worldbank_usaoda_url=h(c.iso2,"DC.DAC.USAL.CD"),d="/aggregates/projects?get=year"+$("#scope_Official_Finance").attr("data-aggregate-params")+("&recipient_iso2="+c.iso2),d3.json("/ajax?url="+worldbank_gni_url,function(b){return d3.json("/ajax?url="+worldbank_dacoda_url,function(c){return d3.json("/ajax?url="+worldbank_usaoda_url,function(e){return d3.json(d,function(g){return a(f,b,[{name:"Chinese O.F.",data:g,source:d,color:"#cc3333"},{name:"DAC ODA",data:c,source:worldbank_dacoda_url,color:"#6699ff"},{name:"USA ODA",data:e,source:worldbank_usaoda_url,color:"cccc66"}],worldbank_gni_url)})})})})},a=function(a,b,c,d){var e,f,g,h,i,j,k,l;return a.selection.transition().attr("height",a.height+a.text_margin+25),l=window.vis_config.years,c.forEach(function(a){var c,d,e,f,g,h,i,j,k,m,n,o;a.graph_data=[];if(a.source.indexOf("api.worldbank")!==-1){n=[];for(g=0,i=l.length;g<i;g++)f=l[g],c=a.data[1].filter(function(a){return Number(a.date)===f})[0],e=(k=b[1].filter(function(a){return Number(a.date)===f})[0])!=null?k.value:void 0,e&&c?(d=[f,100*Number(c.value)/Number(e)],n.push(a.graph_data.push(d))):n.push(void 0);return n}if(a.source.indexOf("aggregates/projects")!==-1){o=[];for(h=0,j=l.length;h<j;h++)f=l[h],c=a.data.filter(function(a){return Number(a.year)===f})[0],e=(m=b[1].filter(function(a){return Number(a.date)===f})[0])!=null?m.value:void 0,c&&e?(d=[f,100*Number(c.usd_current)/Number(e)],o.push(a.graph_data.push(d))):o.push(void 0);return o}}),e=d3.max(c.map(function(a){return d3.max(a.graph_data,function(a){return a[1]})})),h=d3.scale.linear().domain([0,e+e/10]).range([a.height,0]),k=d3.scale.linear().domain([d3.min(l),d3.max(l)]).range([0,a.width]),l.length>=6?i=d3.svg.axis().scale(k).orient("bottom").ticks(6).tickFormat(d3.format("f")):i=d3.svg.axis().scale(k).orient("bottom").tickValues(l).tickFormat(d3.format("f")),a.selection.append("svg:g").attr("class","axis").call(i).style("fill","#ccc").attr("transform","translate(0,"+(a.height+2)+")").attr("opacity",1),j=d3.svg.axis().scale(h).ticks(4).orient("right"),a.selection.append("svg:g").attr("class","axis").call(j).style("fill","#ccc").attr("transform","translate("+a.width+")").attr("opacity",1),f=d3.svg.line().x(function(a){return k(a[0])}).y(function(a){return h(a[1])}),g=3,a.selection.selectAll(".gni_line").data(c).enter().append("svg:path").attr("class","gni_line").attr("d",function(a){return f(a.graph_data)}).style("stroke",function(a){return a.color}).style("fill","transparent").style("opacity",".6").attr("stroke-width",g),a.selection.selectAll(".gni_label").data(c).enter().append("svg:text").attr("class","gni_label").text(function(a){return a.name}).style("fill",function(a){return a.color}).attr("text-anchor","bottom").attr("x",function(a,b){return(3+b*10)/80*window.vis_config.w}).attr("y",a.height+a.text_margin),a.selection.append("svg:text").text("Finance/GNI (%)").style("fill","white").attr("text-anchor","top").attr("y",0).attr("x",a.width/2-this.length/2).style("font-weight","bold"),a.selection.append("svg:foreignObject").attr("x",-0.025*window.vis_config.w).attr("y",a.height+a.text_margin+5).attr("width",a.width+50).attr("height",.025*window.vis_config.h).append("xhtml:body").style("padding","2px 2px 2px 2px").style("background-color","hsla(319, 0%, 100%, 0.5)").style("text-align","center").style("vertical-align","center").html("<p style='color:#333;font-size:"+window.vis_config.medium_font_size+";'>"+("<b>Sources: </b> <a href='"+d+"'>GNI</a>, ")+(""+c.map(function(a){return"<a href='"+a.source+"'>"+a.name+"</a>"}).join(", ")+"</p>"))},window.click=function(){var a,b,e;return a=d(this),b=c(),e="/aggregates/projects?get=crs_sector_name,year"+current_scope.aggregate_params+"&recipient_iso2="+a.iso2+"&multiple_recipients=percent_then_share",$.get(e,function(c){return a.data=c,h(b,a),g(b,a)},"json"),f(b,a)}})).call(this);