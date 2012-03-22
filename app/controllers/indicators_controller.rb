class IndicatorsController < ApplicationController
require 'csv'
  before_filter :authenticate_user!

  # GET /indicators
  # GET /indicators.json
  def index
    @indicators = Indicator.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @indicators }
    end
  end

  # GET /indicators/1
  # GET /indicators/1.json
  def show
    @indicator = Indicator.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @indicator }
    end
  end

  # GET /indicators/new
  # GET /indicators/new.json
  def new
    @indicator = Indicator.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    @locales.length.times {@indicator.indicator_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @indicator }
    end
  end

  # GET /indicators/1/edit
  def edit
    @indicator = Indicator.find(params[:id])
  end

  # POST /indicators
  # POST /indicators.json
  def create
    @indicator = Indicator.new(params[:indicator])

    respond_to do |format|
      if @indicator.save
        format.html { redirect_to @indicator, notice: 'Indicator was successfully created.' }
        format.json { render json: @indicator, status: :created, location: @indicator }
      else
        format.html { render action: "new" }
        format.json { render json: @indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /indicators/1
  # PUT /indicators/1.json
  def update
    @indicator = Indicator.find(params[:id])

    respond_to do |format|
      if @indicator.update_attributes(params[:indicator])
        format.html { redirect_to @indicator, notice: 'Indicator was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @indicator.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /indicators/1
  # DELETE /indicators/1.json
  def destroy
    @indicator = Indicator.find(params[:id])
    @indicator.destroy

    respond_to do |format|
      format.html { redirect_to indicators_url }
      format.json { head :ok }
    end
  end


  # GET /indicators/upload
  # GET /indicators/upload.json
  def upload
		if request.post? && params[:file].present?
logger.debug "content type = #{params[:file].content_type}"
			if params[:file].content_type == "text/csv"
logger.debug "content type is CSV, processing"

		    infile = params[:file].read
		    n, errs = 0, ""

				Indicator.transaction do
				  CSV.parse(infile) do |row|
				    n += 1
				    # SKIP: header i.e. first row OR blank row
				    next if n == 1 or row.join.blank?
				    # build new indicator record
				    ind = Indicator.build_from_csv(row)
				    # Save if valid 
            if !ind.nil?
  				    if ind.valid?
  				      ind.save
  				    else
  				      # an error occurred, stop
  				      errs = "Row #{n} is not valid."
  				      raise ActiveRecord::Rollback
  				      break
  				    end
			      else
  			      # an error occurred, stop
  			      errs = "Row #{n} has an event or shape type that is not in the database or the indicator already exists."
  			      raise ActiveRecord::Rollback
  			      break
            end
				  end
				end
logger.debug " - processed #{n} rows"
		    if errs.length > 0
logger.debug " - errors found!"
					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{errs}"
		      redirect_to upload_indicators_path #GET
		    else
logger.debug " - no errors found!"
					flash[:notice] = "Your file was successfully processed!"
		      redirect_to upload_indicators_path #GET
		    end
			else
logger.debug "content type is NOT CSV, stopping"
				flash[:notice] = "Your file must be a CSV format."
        redirect_to upload_indicators_path #GET
			end
		end
  end



end
