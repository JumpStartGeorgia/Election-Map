class ShapesController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!


  # GET /shapes/upload
  # GET /shapes/upload.json
  def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

		      msg = Shape.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
		      if msg.nil? || msg.length == 0
		        # no errors, success!
						flash[:notice] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to upload_shapes_path #GET
		      else
		        # errors
						flash[:notice] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to upload_shapes_path #GET
		      end 
				else
					flash[:notice] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to upload_shapes_path #GET
				end
			else
				flash[:notice] = I18n.t('app.msgs.upload.no_file')
	      redirect_to upload_data_path #GET
			end
		end
  end


  # GET /shapes/export
  def export
    filename ="shapes_template"
    csv_data = CSV.generate(:col_sep=>',') do |csv|
      csv << Shape.csv_header
    end 
    send_data csv_data,
      :type => 'text/csv; charset=utf-8; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end 
end
