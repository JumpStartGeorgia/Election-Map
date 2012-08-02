class ShapesController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!
	cache_sweeper :shape_sweeper, :only => [:upload, :delete]


  # GET /shapes/upload
  # GET /shapes/upload.json
  def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

		      msg = Shape.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
		      if msg.nil? || msg.empty?
		        # no errors, success!
						flash[:success] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to upload_shapes_path #GET
		      else
		        # errors
						flash[:error] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to upload_shapes_path #GET
		      end
				else
					flash[:error] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to upload_shapes_path #GET
				end
			else
				flash[:error] = I18n.t('app.msgs.upload.no_file')
	      redirect_to upload_shapes_path #GET
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

  # GET /shapes/delete
  # GET /shapes/delete.json
  def delete
		gon.load_js_shape_delete = true
		@events = Event.get_all_events

		if request.post?
			if params[:event_id].nil? || params[:event_id] == "" || params[:shape_type_id].nil? || params[:shape_type_id] == "0"
				flash[:error] = I18n.t('app.msgs.missing_parameters')
			else
				# delete the shapes
				msg = Shape.delete_shapes(params[:event_id], params[:shape_type_id])

				if msg.nil?
					flash[:success] = I18n.t('app.msgs.delete_shapes_success',
					  :event => params[:event_name], :shape_type => params[:shape_type_name].gsub("-", "").strip)

          # reset params
          params[:event_id] = nil
          params[:shape_type_id] = nil

				else
      		gon.event_id = params[:event_id]
      		gon.shape_type_id = params[:shape_type_id]
					flash[:error] = I18n.t('app.msgs.delete_shapes_fail', :msg => msg)
				end
			end
		end
  end


end
