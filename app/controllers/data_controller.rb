class DataController < ApplicationController
	require 'csv'
  before_filter :authenticate_user!
	cache_sweeper :datum_sweeper, :only => [:upload]

  # GET /data/upload
  # GET /data/upload.json
  def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

				  msg = Datum.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
		      if msg.nil? || msg.length == 0
		        # no errors, success!
						flash[:notice] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to upload_data_path #GET
		      else
		        # errors
						flash[:notice] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to upload_data_path #GET
		      end 
				else
					flash[:notice] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to upload_data_path #GET
				end
			else
				flash[:notice] = I18n.t('app.msgs.upload.no_file')
	      redirect_to upload_data_path #GET
			end
		end
  end

  # GET /data/export
  def export
    filename ="data_template"
    csv_data = CSV.generate(:col_sep=>',') do |csv|
      csv << Datum.csv_header
    end 
    send_data csv_data,
      :type => 'text/csv; charset=utf-8; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end 

end
