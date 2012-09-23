class DataController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :datum_sweeper, :only => [:upload]

  # GET /data/upload
  # GET /data/upload.json
  def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
					start = Time.now
				  msg = Datum.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
		      if msg.nil? || msg.empty?
		        # no errors, success!
						msg = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
						flash[:success] = msg
						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
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
		@events = Event.get_all_events_by_date

		if request.post?
			if params[:event_id].nil? || params[:event_id] == ""
				flash[:error] = I18n.t('app.msgs.missing_parameters')
			else
				start = Time.now
				# delete the data
				params[:shape_type_id] = nil if params[:shape_type_id] == "" || params[:shape_type_id] == "0"
				params[:indicator_id] = nil if params[:indicator_id] == "" || params[:indicator_id] == "0"
				msg = Datum.delete_data(params[:event_id], params[:shape_type_id], params[:indicator_id])

				if msg.nil?
					if !params[:shape_type_id].nil? && !params[:indicator_id].nil?
						msg = I18n.t('app.msgs.delete_data_success_1',
						  :event => params[:event_name], :shape_type => params[:shape_type_name].gsub("-", "").strip,
							:indicator => params[:indicator_name])
						flash[:success] = msg
						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
					elsif !params[:shape_type_id].nil?
						msg = I18n.t('app.msgs.delete_data_success_2',
						  :event => params[:event_name], :shape_type => params[:shape_type_name].gsub("-", "").strip)
						flash[:success] = msg
						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
					else
						msg = I18n.t('app.msgs.delete_data_success_3',
						  :event => params[:event_name])
						flash[:success] = msg
						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
					end

          # reset params
          params[:event_id] = nil
          params[:shape_type_id] = nil
          params[:indicator_id] = nil

				else
      		gon.event_id = params[:event_id]
      		gon.shape_type_id = params[:shape_type_id]
      		gon.indicator_type_id = params[:indicator_id]
					flash[:error] = I18n.t('app.msgs.delete_data_fail', :msg => msg)
				end
			end
		end
  end

end
