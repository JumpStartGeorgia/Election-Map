class DataController < ApplicationController
require 'csv'

  before_filter :authenticate_user!

  # GET /data/upload
  # GET /data/upload.json
  def upload
		if request.post? && params[:file].present?
			if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

		    msg = Datum.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
        if msg.nil? || msg.length == 0
          # no errors, success!
					flash[:notice] = "Your file '#{params[:file].original_filename}' was successfully processed!"
		      redirect_to upload_data_path #GET
        else
          # errors
					flash[:notice] = "Errors were encountered with '#{params[:file].original_filename}' and no records were saved.  The problem was the following: #{msg}"
		      redirect_to upload_data_path #GET
        end 
			else
				flash[:notice] = "Your file '#{params[:file].original_filename}' must be a CSV or tab-delimited txt format."
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
