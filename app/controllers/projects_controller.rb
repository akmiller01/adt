class ProjectsController < ApplicationController  
skip_before_filter :signed_in_user, only: [:suggest, :to_english]
before_filter :set_owner, only: [:create, :new]
before_filter :correct_owner?, only: [:edit, :destroy]
before_filter :aiddata_only!, only: [:create]

# before_filter :lock_editing_except_for_admins, except: [:index, :show, :suggest]

include SearchHelper
extend Typeaheadable
enable_typeahead Project, facets: {active_string: "Active"}
 #caches_action :show, cache_path: proc { |c| "projects/#{c.params[:id]}/#{signed_in? ? current_user.id : "not_signed_in"}/}
 #caches_action :index, expires_in: 1.hour, unless: proc { |c| current_user_is_aiddata }

 cache_sweeper :project_sweeper # app/models/project_sweeper.rb
  
  def index
   
    respond_to do |format|
      format.html do
        @full_result_ids = custom_search(paginate: false).map(&:id)
   			@projects = custom_search
        @export = Export.new(params[:export])

        @project_facet_counts = Rails.cache.fetch("projects/faceted") do
          # wipe it in ProjectSweeper!
          p "---------------- STARTING CACHE -------------------------"
          facets = (WORKFLOW_FACETS + FACETS)
          all_projects = Project.search do
            facets.each do |f|
              facet f[:sym]
            end
          end
          facet_counts = {}          
          facets.each do |f|
            facet_values = all_projects.facet(f[:sym]).rows.sort!{|a,b| a.value <=> b.value}.map(&:value)
            facet_counts[f[:sym]] = facet_values
          end
          facet_counts
        end 

        render html: @projects
      end
      format.json do
				@projects = custom_search({default_to_official_finance: false})
        render json: @projects
      end
      format.csv do
        p params.inspect
        if params[:page]
          @paginate = true
        else
          @paginate = false
        end

   			projects = custom_search(paginate: @paginate, default_to_official_finance: false)
        
        csv_data = projects.map{|p| p.csv_text } .join("\n")				
				
        csv_header = Project.csv_header
        csv_data = (csv_header + "\n" + csv_data)

        send_data csv_data,
          :type => 'text/csv; charset=utf-8; header=present',
          :disposition => "attachment; filename=AidData_China_custom_#{Time.now.strftime("%y-%m-%d-%H:%M:%S-%L")}.csv"


      end
    end
  end


  def show
    @project = Project.unscoped.find(params[:id])
    @comment = Comment.new
    @flags = @project.all_flags
    @flag = Flag.new
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)





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
    @flow_class = @project.flow_class = FlowClass.new
    @loan_detail = @project.loan_detail = LoanDetail.new


    warn_that_data_is_frozen

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /Projects/1/edit
  def edit

    warn_that_data_is_frozen
    
    @project = Project.unscoped.find(params[:id])
    @flow_class = FlowClass.find_or_create_by_project_id(@project.id)
    @loan_detail = LoanDetail.find_or_create_by_project_id(@project.id)

  end

  # POST /Projects
  # POST /Projects.json
  def create
    @project = Project.new(params[:project])

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
    @project = Project.unscoped.find(params[:id])

    #for versioning
    @project.save_state

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
  	
  
    @project = Project.unscoped.find(params[:id])
    
    # The big problem here was that in @project.destroy, 
    # all the accessory objects were destroyed _first_,
    # so when @project was destroyed (and accessories were saved),
    # the accessories were gone already and accessories was an empty array.
    #
    # To get around this, I'm saving the accessories, deleting everything,
    # then adding the accessories by hand. 
    
    @accessories = @project.accessories
    
    @project.destroy
   
    
    @last_version = @project.versions.scoped.last
    @last_version.accessories = @accessories
    @last_version.save!

    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
    
    undo_link = view_context.link_to( 
    "Undo", revert_version_path(@project.versions.scoped.last
    ),
    method: :post)
    flash[:notice] = "Project deleted! #{undo_link}"
  end

  def suggest 
    if request.post?
      @project = Project.new(params[:project])
      @project.published = false
      @project.donor = Country.find_by_name("China")
      if @project.save
        flash[:success] = "We will review your aid project suggestion"
      else
        flash[:error] = "Sorry -- that operation failed, please try again."
      end
      redirect_to :back
    end
    # suggest.html.haml
  end

  private

    def lock_editing_except_for_admins
      warn_that_data_is_frozen

      if !current_user_is_aiddata_admin
        redirect_to Project.find(params[:id])
      else
        flash[:notice] = "You have access because you are an AidData admin."
      end

    end

    def correct_owner? 
      project_owner = Project.unscoped.find(params[:id]).owner 
      if ( 
          (project_owner && (signed_in? && current_user.owner.present? && (current_user.owner == project_owner)))||
          (current_user_is_aiddata && project_owner.nil?)
        )
        true
      else
        flash[:notice] = "Only #{project_owner.name} can edit this record."
        redirect_to Project.find(params[:id])

      end
    end
    
    def set_owner
      if signed_in?
        current_user.owner 
      else 
        Organization.find_by_name("AidData")
      end
    end
  

    def warn_that_data_is_frozen
      flash[:danger] = "This dataset is <b>frozen</b> until release! <b>You can't add or edit</b> any data."
    end

end
