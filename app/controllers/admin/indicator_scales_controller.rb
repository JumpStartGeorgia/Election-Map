class Admin::IndicatorScalesController < ApplicationController
  before_filter :authenticate_user!
	cache_sweeper :indicator_scale_sweeper, :only => [:upload]

	# GET /indicator_scales/upload
	# GET /indicator_scales/upload.json
	def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
					start = Time.now
					msg = IndicatorScale.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
			    if msg.nil? || msg.empty?
			      # no errors, success!
						msg = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
						flash[:success] = msg
						send_status_update(I18n.t('app.msgs.cache_cleared', :action => msg), Time.now-start)
					  redirect_to upload_admin_indicator_scales_path #GET
			    else
			      # errors
						flash[:error] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
					  redirect_to upload_admin_indicator_scales_path #GET
			    end
				else
					flash[:error] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
			    redirect_to upload_admin_indicator_scales_path #GET
				end
			else
				flash[:error] = I18n.t('app.msgs.upload.no_file')
	      redirect_to upload_admin_indicator_scales_path #GET
			end
		end
	end


	# GET /indicator_scales/export
	def export
	  filename ="indicator_sacles_template"
	  csv_data = CSV.generate(:col_sep=>',') do |csv|
	    csv << IndicatorScale.csv_all_header
	  end
	  send_data csv_data,
	    :type => 'text/csv; charset=utf-8; header=present',
	    :disposition => "attachment; filename=#{filename}.csv"
	end

end
