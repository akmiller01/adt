class FilesController < ApplicationController
skip_before_filter :signed_in_user, only: [:create]
before_filter :is_project_owner?, only: [:edit, :destroy]

	AIDDATA_FS ='http://aiddata-fs.herokuapp.com/files/china'
	AIDDATA_FS_PASSWORD = ENV['AIDDATA_FS_PASSWORD']
	AIDDATA_FS_USERNAME = ENV['AIDDATA_FS_USERNAME']

# HTTP Verb	Path								action	used for
# DELETE	/magazines/:magazine_id/ads/:id		destroy	delete a specific ad belonging to a specific magazine
	
	def index
		require 'net/http'

		uri = URI("#{AIDDATA_FS}/#{params[:project_id]}")
		res = Net::HTTP.get_response(uri)
		
		render json: JSON.parse(res.body)
	end

	def new
		redirect_to Project.find(params[:project_id])
	end


	def create
		
		if params[:file]
			require 'base64'
			require 'net/http'
			require 'net/http/post/multipart'

			uploaded_io = params[:file]
			url = URI.parse("#{AIDDATA_FS}/#{params[:project_id]}")	
			
			# p url

			# p "SENDING FILE"

			# p this_file =  uploaded_io.tempfile

			File.open(this_file, 'r') do |file|
				
				req = Net::HTTP::Post::Multipart.new url,
					"file" => UploadIO.new(file, uploaded_io.content_type, uploaded_io.original_filename)
				req.basic_auth AIDDATA_FS_USERNAME, AIDDATA_FS_PASSWORD

				res = Net::HTTP.start(url.host, url.port) do |http|
					http.request(req)
				end
			end

		end
		
		redirect_to Project.find(params[:project_id])


	end

	def show
		redirect_to Project.find(params[:project_id])
	end

	def edit
		redirect_to Project.find(params[:project_id])
	end

	def update
		redirect_to Project.find(params[:project_id])
	end

	def delete
		require 'net/http'

		url = URI.parse("#{AIDDATA_FS}/#{params[:project_id]}/#{params[:file_id]}")	
		
		req = Net::HTTP::Delete.new(url)
		req.basic_auth AIDDATA_FS_USERNAME, AIDDATA_FS_PASSWORD

		Net::HTTP.request(req)

		flash[:notice] = "File deleted."
		redirect_to Project.find(params[:project_id])
	end

	private

    def correct_owner? 
      project_owner = Project.find(params[:project_id]).owner 
      if ( 
          (project_owner && (signed_in? && current_user.owner.present? && (current_user.owner == project_owner)))||
          (current_user_is_aiddata && project_owner.nil?)
        )
        true
      else
        flash[:notice] = "Only #{project_owner.name} can edit this file."
        redirect_to Project.find(params[:id])
      end
    end
    
end
