# encoding: utf-8

class IndicatorsController < ApplicationController
	require 'csv'
  before_filter :authenticate_user!
	cache_sweeper :indicator_sweeper, :only => [:upload, :change_name]

  # GET /indicators/upload
  # GET /indicators/upload.json
  def upload
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

				  msg = Indicator.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
		      if msg.nil? || msg.length == 0
		        # no errors, success!
						flash[:notice] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to upload_indicators_path #GET
		      else
		        # errors
						flash[:notice] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to upload_indicators_path #GET
		      end 
				else
					flash[:notice] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to upload_indicators_path #GET
				end
			else
				flash[:notice] = I18n.t('app.msgs.upload.no_file')
	      redirect_to upload_indicators_path #GET
			end
		end
  end


  # GET /indicators/export
  def export
    filename ="indicators_template"
    csv_data = CSV.generate(:col_sep=>',') do |csv|
      csv << Indicator.csv_all_header
    end 
    send_data csv_data,
      :type => 'text/csv; charset=utf-8; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end 

  # GET /indicators/change_name
  # GET /indicators/change_name.json
  def change_name
		if request.post?
			if params[:file].present?
				if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"
				  msg = Indicator.change_names_from_csv(params[:file])
		      if msg.nil? || msg.length == 0
		        # no errors, success!
						flash[:notice] = I18n.t('app.msgs.upload.success', :file_name => params[:file].original_filename)
				    redirect_to change_name_indicators_path #GET
		      else
		        # errors
						flash[:notice] = I18n.t('app.msgs.upload.error', :file_name => params[:file].original_filename, :msg => msg)
				    redirect_to change_name_indicators_path #GET
		      end 
				else
					flash[:notice] = I18n.t('app.msgs.upload.wrong_format', :file_name => params[:file].original_filename)
		      redirect_to change_name_indicators_path #GET
				end
			else
				flash[:notice] = I18n.t('app.msgs.upload.no_file')
	      redirect_to change_name_indicators_path #GET
			end
		end
  end


  # GET /indicators/export_name_change
  def export_name_change
    filename ="indicators_name_template"
    csv_data = CSV.generate(:col_sep=>',') do |csv|
      csv << Indicator.csv_change_name_header
    end 
    send_data csv_data,
      :type => 'text/csv; charset=utf-8; header=present',
      :disposition => "attachment; filename=#{filename}.csv"
  end 

  # GET /indicators/download
  # GET /indicators/download.json
  def download
    @events = Event.get_all_events
    
		if request.post?
      event = nil
      @events.each do |e|
        if e.id.to_s == params[:event_id]
          event = e
          break
        end
      end

      if event.nil?
        # no matching event found
				flash[:notice] = I18n.t('app.msgs.download.unknow_event')
	      redirect_to download_indicators_path #GET
      else
        #get the data
        obj = nil # will have csv_data and msg attribute
        case params[:download_option]
        when "names"
logger.debug "controller - getting indicator names only"
          filename ="Indicator_Names_for_"
          obj = Indicator.create_csv(params[:event_id], true)
        when "scales"
logger.debug "controller - getting scales names only"
filename ="Indicator_Scales_for_"
          obj = IndicatorScale.create_csv(params[:event_id])
        when "both"
logger.debug "controller - getting all info"
filename ="Indicator_Names_Scales_for_"
          obj = Indicator.create_csv(params[:event_id], false)
        end
logger.debug "obj = #{obj}"
logger.debug "csv data = #{obj.csv_data}"
logger.debug "msg = #{obj.msg}"
        if !obj.msg.nil?
  				flash[:notice] = I18n.t('app.msgs.download.error', :event_name => event.name, :msg => obj.msg)
  	      redirect_to download_indicators_path #GET
				elsif obj.csv_data.nil? || obj.csv_data.length == 0
  				flash[:notice] = I18n.t('app.msgs.download.no_records', :event_name => event.name)
  	      redirect_to download_indicators_path #GET
        else
          # send the file
          filename << event.name.gsub(' ', '_')
					#remove bad characters
					filename.gsub!(/[\\ \/ \: \* \? \" \< \> \| \, \. ]/,'')
          send_data obj.csv_data,
            :type => 'text/csv; charset=utf-8; header=present',
            :disposition => "attachment; filename=#{filename}.csv"
        end
      end
		end
  end


end
