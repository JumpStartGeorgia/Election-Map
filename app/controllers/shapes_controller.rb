class ShapesController < ApplicationController
  require 'csv'
  before_filter :authenticate_user!

  # GET /shapes
  # GET /shapes.json
  def index
    @shapes = Shape.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @shapes }
    end
  end

  # GET /shapes/1
  # GET /shapes/1.json
  def show
    @shape = Shape.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @shape }
    end
  end

  # GET /shapes/new
  # GET /shapes/new.json
  def new
    @shape = Shape.new
    # create the translation object for however many locales there are
    # so the form will properly create all of the nested form fields
    @locales.length.times {@shape.shape_translations.build}

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @shape }
    end
  end

  # GET /shapes/1/edit
  def edit
    @shape = Shape.find(params[:id])
  end

  # POST /shapes
  # POST /shapes.json
  def create
    @shape = Shape.new(params[:shape])

    respond_to do |format|
      if @shape.save
        format.html { redirect_to @shape, notice: 'Shape was successfully created.' }
        format.json { render json: @shape, status: :created, location: @shape }
      else
        format.html { render action: "new" }
        format.json { render json: @shape.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /shapes/1
  # PUT /shapes/1.json
  def update
    @shape = Shape.find(params[:id])

    respond_to do |format|
      if @shape.update_attributes(params[:shape])
        format.html { redirect_to @shape, notice: 'Shape was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @shape.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shapes/1
  # DELETE /shapes/1.json
  def destroy
    @shape = Shape.find(params[:id])
    @shape.destroy

    respond_to do |format|
      format.html { redirect_to shapes_url }
      format.json { head :ok }
    end
  end

  # GET /shapes/upload
  # GET /shapes/upload.json
  def upload
		if request.post? && params[:file].present?
			if params[:file].content_type == "text/csv" || params[:file].content_type == "text/plain"

        msg = Shape.build_from_csv(params[:file], params[:delete_records].nil? ? nil : true)
        if msg.nil? || msg.length == 0
          # no errors, success!
					flash[:notice] = "Your file was successfully processed!"
		      redirect_to upload_shapes_path #GET
        else
          # errors
					flash[:notice] = "Errors were encountered and no records were saved.  The problem was the following: #{msg}"
		      redirect_to upload_shapes_path #GET
        end 
			else
				flash[:notice] = "Your file must be a CSV or tab-delimited txt format."
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
end
