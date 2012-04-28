class IndicatorsController < ApplicationController
require 'csv'
  before_filter :authenticate_user!

  # GET /indicators/upload
  # GET /indicators/upload.json
  def upload
		if request.post? && params[:file].present?
			if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

		    msg = Indicator.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
        if msg.nil? || msg.length == 0
          # no errors, success!
					flash[:notice] = "Your file was successfully processed!"
		      redirect_to upload_indicators_path #GET
        else
          # errors
					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{msg}"
		      redirect_to upload_indicators_path #GET
        end 
			else
				flash[:notice] = "Your file must be a CSV or tab-delimited txt format."
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
		if request.post? && params[:file].present?
			if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

		    msg = Indicator.change_names_from_csv(params[:file])
        if msg.nil? || msg.length == 0
          # no errors, success!
					flash[:notice] = "Your file was successfully processed!"
		      redirect_to change_name_indicators_path #GET
        else
          # errors
					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{msg}"
		      redirect_to change_name_indicators_path #GET
        end 
			else
				flash[:notice] = "Your file must be a CSV or tab-delimited txt format."
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
				flash[:notice] = "The selected event could not be found."
	      redirect_to download_indicators_path #GET
      else
        #get the data
        csv_data = nil
        case params[:download_option]
        when "names"
logger.debug "controller - getting indicator names only"
          filename ="Indicator_Names_for_"
          csv_data = Indicator.create_csv(params[:event_id], true)
        when "scales"
logger.debug "controller - getting scales names only"
filename ="Indicator_Scales_for_"
          csv_data = IndicatorScale.create_csv(params[:event_id])
        when "both"
logger.debug "controller - getting all info"
filename ="Indicator_Names_Scales_for_"
          csv_data = Indicator.create_csv(params[:event_id], false)
        end

        if csv_data.nil?
  				flash[:notice] = "Errors were encountered and the csv file for '#{event.name}' could not be created."
  	      redirect_to download_indicators_path #GET
        else
          # send the file
          filename << event.name.gsub(' ', '_')
          send_data csv_data,
            :type => 'text/csv; charset=utf-8; header=present',
            :disposition => "attachment; filename=#{filename}.csv"
        end
      end
		end
  end


end
