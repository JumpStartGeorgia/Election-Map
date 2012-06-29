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
		      if msg.nil? || msg.empty?
		        # no errors, success!
						flash[:success] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to upload_data_path #GET
		      else
		        # errors
						flash[:error] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to upload_data_path #GET
		      end 
				else
					flash[:error] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to upload_data_path #GET
				end
			else
				flash[:error] = I18n.t('app.msgs.upload.no_file')
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

  # GET /data/delete
  # GET /data/delete.json
  def delete
		gon.load_js_data_delete = true
		@events = Event.get_all_events

		if request.post?
			if params[:event_id].nil?
				flash[:error] = I18n.t('app.msgs.missing_parameters')
			else
				# delete the data
=begin
				msg = Datum.delete_data(params[:event_id], params[:shape_type_id], params[:indicator_id])

				if msg.nil?				
          # reset params
          params[:event_id] = nil
          params[:shape_type_id] = nil
          params[:indicator_id] = nil
        
  				flash[:success] = I18n.t('app.msgs.delete_data_success', 
  				  :event => params[:event_name], :shape_type => params[:shape_type_name])
				else
      		gon.event_id = params[:event_id]
      		gon.shape_type_id = params[:shape_type_id]
      		gon.indicator_type_id = params[:indicator_id]
					flash[:error] = I18n.t('app.msgs.delete_data_fail', :msg => msg)
				end
=end
			end
		end
  end

end
