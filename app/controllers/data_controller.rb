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
			if params[:event_id].nil? || params[:shape_type_id].nil? || params[:shape_type_id] == "0"
				flash[:error] = I18n.t('app.msgs.missing_parameters')
			else
				# delete the data
=begin
				msg = Datum.delete_data(params[:event_id], params[:shape_type_id])

				if msg.nil?				
					# get the name of the event and shape type
					event, shape_type = "", ""
					@events.each do |e|
						event = e.name if e.id.to_s() == params[:event_id]
					end
					@shape_types.each do |st|
						shape_type = st.name_singular if st.id.to_s() == params[:shape_type_id]
					end
					flash[:success] = I18n.t('app.msgs.delete_shapes_success', :event => event, :shape_type => shape_type)
				else
					flash[:error] = I18n.t('app.msgs.delete_shapes_fail', :msg => msg)
				end
=end
			end
		end
  end

end
