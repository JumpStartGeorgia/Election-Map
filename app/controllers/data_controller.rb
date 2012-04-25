class DataController < ApplicationController
require 'csv'

  before_filter :authenticate_user!

  # GET /data
  # GET /data.json
  def index
    @data = Datum.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @data }
    end
  end

  # GET /data/1
  # GET /data/1.json
  def show
    @datum = Datum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @datum }
    end
  end

  # GET /data/new
  # GET /data/new.json
  def new
    @datum = Datum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @datum }
    end
  end

  # GET /data/1/edit
  def edit
    @datum = Datum.find(params[:id])
  end

  # POST /data
  # POST /data.json
  def create
    @datum = Datum.new(params[:datum])

    respond_to do |format|
      if @datum.save
        format.html { redirect_to @datum, notice: 'Datum was successfully created.' }
        format.json { render json: @datum, status: :created, location: @datum }
      else
        format.html { render action: "new" }
        format.json { render json: @datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /data/1
  # PUT /data/1.json
  def update
    @datum = Datum.find(params[:id])

    respond_to do |format|
      if @datum.update_attributes(params[:datum])
        format.html { redirect_to @datum, notice: 'Datum was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @datum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /data/1
  # DELETE /data/1.json
  def destroy
    @datum = Datum.find(params[:id])
    @datum.destroy

    respond_to do |format|
      format.html { redirect_to data_url }
      format.json { head :ok }
    end
  end

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
