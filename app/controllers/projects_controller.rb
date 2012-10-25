class ProjectsController < ApplicationController  
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit]
#before_filter :strip_tags_from_description, only: [:create, :update]


  def index
     


    respond_to do |format|
      format.html do 
        custom_search
        render html: @projects
      end
      format.json do
        custom_search
        render json: @projects.as_json(
          only: [:id,:year], 
          methods: [:usd_2009],
          include: [
            {donor:{only: [:name]}}, 
            {geopoliticals: {include: [recipient: {only: [:name, :iso2]}], only: [:percent]}}, 
            {sector: {only: [:name]}}
            ]) 
      end
      format.csv do
        params[:max] = Project.all.count
        custom_search
        @export_projects = Project.where("id in(?)", 
          @projects.map{ |p| p.id})
        send_data @export_projects.to_csv
      end
    end
  end

  # GET /Projects/1
  # GET /Projects/1.json
  def show
    @project = Project.find(params[:id])
    @comment = Comment.new

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/new
  # GET /Projects/new.json
  def new
    @project = Project.new(owner: @new_owner)
    @project.transactions.build
    @project.geopoliticals.build
    @project.participating_organizations.build
    @project.contacts.build
    @project.sources.build


    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/1/edit
  def edit
    @project = Project.find(params[:id])
  end

  # POST /Projects
  # POST /Projects.json
  def create
    @project = Project.new(params[:project])
    strip_tags_from_description
    deflate_project_values(@project)
    
    respond_to do |format|
      if @project.save
        format.html { redirect_to @project }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end


  end

  # PUT /Projects/1
  # PUT /Projects/1.json
  def update
    @project = Project.find(params[:id])
    deflate_project_values(@project)

    respond_to do |format|
      if @project.update_attributes(params[:project])
        format.html { redirect_to @project }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end

    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@project.versions.scoped.last
    ),
    #"Undo", "/versions/#{@object.versions.last.id}/revert",
    method: :post)
    flash[:success] = "Project updated. #{undo_link}"
  end

  # DELETE /Projects/1
  # DELETE /Projects/1.json
  def destroy
    @project = Project.find(params[:id])
    @project.destroy

    respond_to do |format|
      format.html { redirect_to Projects_url }
      format.json { head :no_content }
    end
  end

  def media
    @project = Project.find_by_media_id(params[:media_id])
    if current_user && @project.owner == Organization.find_by_name('AidData') && current_user.owner == Organization.find_by_name("AidData")
      render 'edit'
    else
      render 'show'
    end
  end


  private

    def correct_owner? 
      project_owner = Project.find(params[:id]).owner 
      unless signed_in? && current_user.owner.present? && (current_user.owner == project_owner)
        flash[:notice] = "Only #{project_owner.name} can edit this record."
        redirect_to Project.find(params[:id])
      end

    end
    def set_owner
      @new_owner = current_user.owner if signed_in?
    end

    def deflate_value(value,currency_iso3, yr, donor_iso3)
      require 'open-uri'
      deflator_query = "#{value.to_s}#{currency_iso3}#{yr}#{donor_iso3}"
      deflator_url = "https://oscar.itpir.wm.edu/deflate/api.php?val=#{deflator_query}"
      deflated_amount = open(deflator_url){|io| io.read}
    end

    def deflate_project_values(project)
      if project.donor.present? && project.year.present? 
        
        donor_iso3 = project.donor.iso3 
        year = project.year

        project.transactions.each do |t|
          if t.value.present? and t.value > 0 and t.currency.present?
            deflated_amount = deflate_value(t.value, t.currency.iso3, year, donor_iso3)

            t.usd_defl=deflated_amount.to_f
          else
            t.usd_defl=nil
          end
        end
      end

    end

    def strip_tags_from_description
      @project.description = view_context.strip_tags(@project.description)
      
      # hack when data uploading
      # if @project.title.blank?
      #   @project.title = "Unset"
      # end

    end
  
  def custom_search(options = {})
    options.reverse_merge! paginate: true

     @facet_labels = ["Sector", "Flow Type", "Flow Class", "Is Commercial", "Active", "Recipient"]
      @facets = facets = [
        {sym: :sector_name, name: "Sector"},
        {sym: :flow_type_name, name: "Flow Type"},
        {sym: :oda_like_name, name: "Flow Class"},
        {sym: :status_name, name:"Status"},
        {sym: :tied_name, name:"Tied/Untied"},
        {sym: :verified_name, name:"Verified/Unverified"},
        {sym: :currency_name, name:"Reported Currency"},
        {sym: :is_commercial_string, name: "Commericial Status"},
        {sym: :active_string, name: "Active/Inactive"},
        {sym: :country_name, name: "Recipient"},
        {sym: :source_type_name, name: "Source Type"},
        {sym: :document_type_name, name: "Document Type"},
        {sym: :origin_name, name: "Organization Origin"},
        {sym: :role_name, name: "Organization Role"},
        {sym: :organization_type_name, name: "Organization Type"},
        {sym: :organization_name, name: "Organization Name"},
        {sym: :owner_name, name: "Record Owner"}
      ].sort! { |a,b| a[:name] <=> b[:name] }
      @search = Project.search do
          fulltext params[:search]
          facets.each do |f|
            facet f[:sym]
            with f[:sym], params[f[:sym]] if params[f[:sym]].present?
          order_by((params[:order_by] ? params[:order_by].to_sym : :title), params[:dir] ? params[:dir].to_sym : :desc )
      end
      
    
      if options[:paginate]==true
        paginate :page => params[:page] || 1, :per_page => params[:max] || 50
      end
    end
    @projects = @search.results
  end


end
