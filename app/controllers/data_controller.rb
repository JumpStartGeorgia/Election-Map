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
logger.debug "content type = #{params[:file].content_type}"
			if params[:file].content_type == "text/csv"
logger.debug "content type is CSV, processing"

		    infile = params[:file].read
		    n, errs = 0, ""

				Datum.transaction do
				  CSV.parse(infile) do |row|
				    n += 1
				    # SKIP: header i.e. first row OR blank row
				    next if n == 1 or row.join.blank?
				    # build new data record for all data in this row
				    data = Datum.build_from_csv(row)
				    # Save if valid 
            if !data.nil? && data.length > 0
							data.each do |datum|
						    if datum.valid?
						      datum.save
						    else
						      # an error occurred, stop
						      errs = "Row #{n} is not valid."
						      raise ActiveRecord::Rollback
						      break
						    end
							end
			      else
  			      # an error occurred, stop
  			      errs = "Row #{n} has an event or shape type or indicator that is not in the database or the data record already exists."
  			      raise ActiveRecord::Rollback
  			      break
            end
				  end
				end
logger.debug " - processed #{n} rows"
		    if errs.length > 0
logger.debug " - errors found!"
					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{errs}"
		      redirect_to upload_data_path #GET
		    else
logger.debug " - no errors found!"
					flash[:notice] = "Your file was successfully processed!"
		      redirect_to upload_data_path #GET
		    end
			else
logger.debug "content type is NOT CSV, stopping"
				flash[:notice] = "Your file must be a CSV format."
        redirect_to upload_data_path #GET
			end
		end
  end


end
